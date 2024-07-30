import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cnic_scanner/cnic_scanner.dart';
import 'package:cnic_scanner/model/cnic_model.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:crimebook/blocs/sign_in_bloc.dart';
import 'package:crimebook/pages/done.dart';
import 'package:crimebook/utils/toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crimebook/blocs/all_crime_bloc/ciminal_bloc.dart'; // Import your CriminalBloc
import 'package:crimebook/models/all_crime_models/criminals.dart';
import 'package:crimebook/pages/phoneAuthScreen.dart';
import 'package:crimebook/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crimebook/utils/buttons.dart';

import '../blocs/getxLogics/user_logic.dart';
import '../config/firebase_config.dart';
import '../models/userModel.dart'; // Assuming you have this widget

class SignUpPage2 extends StatefulWidget {
  final String? tag;

  SignUpPage2({Key? key, this.tag}) : super(key: key);

  @override
  State<SignUpPage2> createState() => _SignUpPage2State();
}

class _SignUpPage2State extends State<SignUpPage2> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  List<XFile> _selectedMedia = [];
  String? cnicUrl;
  String? profilePicUrl;
  bool isLoading = false;
  bool isSavingCriminal = false;
  bool isImageUploaded = false;
  bool isCnicUploaded = false;
  final _phoneNumberController = TextEditingController();
  final _cnicController = TextEditingController();
  final _dobController = TextEditingController();
  final _issueDate = TextEditingController();
  final _expiryDate = TextEditingController();
  String? _verificationId;
  String? _smsCode;
  UserType? selectedUserType;
  UserGender? selectedUserGender;
  String? name;
  String? cnic;
  String? phoneNumber;
  bool signUpCompleted = false;
  bool signUpStarted = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _selectMedia() async {
    try {
      final List<XFile>? pickedMedia = await _picker.pickMultiImage(imageQuality: 50);
      if (pickedMedia != null && pickedMedia.isNotEmpty) {
        setState(() {
          _selectedMedia = pickedMedia;
        });
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  Future<void> _uploadCNICImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: source);

      // Determine format based on image type (e.g., img.Format.jpeg)

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('users')
            .child('${FirebaseAuth.instance.currentUser!.uid}')
            .child('cnic')
            .child('cnic.jpg');
        try {
          final uploadTask = await storageRef.putFile(file);
          cnicUrl = await uploadTask.ref.getDownloadURL();
          print('CNIC Image URL: $cnicUrl');
        } catch (e) {
          print('Error uploading CNIC Image: $e');
        }
      }
    } catch (e) {
      print('Error picking CNIC Image: $e');
    }
  }

  // Function to upload Profile Picture to Firebase Storage
  Future<void> _uploadProfilePicture() async {
    setState(() {
      isLoading = true;
    });

    XFile? pickedProfileImage = await _picker.pickImage(source: ImageSource.gallery);
    var uC = Get.find<UserLogic>();
    print("my id");
    print(uC.currentUser.value!.uid);

    if (pickedProfileImage != null) {
      final file = File(pickedProfileImage.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child('${uC.currentUser.value!.uid}')
          .child('profile')
          .child('profile.jpg');
      try {
        final uploadTask = await storageRef.putFile(file);
        profilePicUrl = await uploadTask.ref.getDownloadURL();
        setState(() {});
        print('Profile Picture URL: $profilePicUrl');
      } catch (e) {
        print('Error uploading Profile Picture: $e');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  //Widget for circular Image
  Widget _circularImage(context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          isLoading = true;
        });
        await _uploadProfilePicture();
        setState(() {
          isLoading = false;
        });
      },
      child: CircleAvatar(
        radius: 50, // Adjust the radius as needed
        backgroundColor: Colors.grey[300],
        child: profilePicUrl == null
            ? Icon(Icons.image, color: Colors.grey[700])
            : isLoading
                ? SizedBox(
                    width: 32.0, height: 32.0, child: new CupertinoActivityIndicator())
                : ClipOval(
                    child: Image.network(
                      profilePicUrl!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  ),
      ),
    );
  }

  // Save User Details to Firestore
  bool allChecksPassed() {
    if (_cnicModel.cnicNumber.isEmpty) {
      openToast(context, 'Try uploading cnic again');
      return false;
    } else if (selectedUserType == null) {
      openToast(context, 'Please select User type');
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _saveUserDetails() async {
    var sb = Provider.of<SignInBloc>(context, listen: false);
    var uC = Get.find<UserLogic>();
    DateFormat formatter = DateFormat('dd/MM/yyyy');

    if (allChecksPassed() == false) {
      return false;
    }
    var newUser = MyUser(
      uid: FirebaseAuth.instance.currentUser!.uid,
      name: uC.currentUser.value!.name ??
          FirebaseAuth.instance.currentUser!.displayName ??
          '',
      email:
          uC.currentUser.value!.email ?? FirebaseAuth.instance.currentUser!.email ?? '',
      cnicNo: _cnicModel.cnicNumber,
      cnicDob: formatter.parse(_cnicModel.cnicHolderDateOfBirth),
      cnicExpiryDate: formatter.parse(_cnicModel.cnicExpiryDate),
      cnicIssueDate: formatter.parse(_cnicModel.cnicIssueDate),
      phoneNumber: phoneNumber,
      profilePicUrl: profilePicUrl,
      gender: selectedUserGender != null && selectedUserGender!.name == UserGender.female
          ? UserGender.female
          : UserGender.male,
      userType: selectedUserType,
    );
    uC.currentUser.value = newUser;
    uC.currentUser.refresh();

    try {
      await FirebaseFirestore.instance
          .collection(FirebaseConfig.usersCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(uC.currentUser.value!.toJSON())
          .then((value) {
        sb.getTimestamp().then((value) => sb.increaseUserCount()).then((value) => sb
            .guestSignout()
            .then(
                (value) => sb.saveDataToSP().then((value) => sb.setSignIn().then((value) {
                      setState(() {
                        signUpCompleted = true;
                      });
                      // afterSignUp();
                    }))));
      });
      return true;

      // ... (Navigate to the next screen or handle success) ...
    } catch (e) {
      print('Error saving user details: $e');
      return false;
    }
  }

  afterSignUp() {
    if (widget.tag == null) {
      nextScreenReplace(context, DonePage());
    } else {
      Navigator.pop(context);
    }
  }

  CnicModel _cnicModel = CnicModel();
  bool showCnicDetails = false;

  TextEditingController nameTEController = TextEditingController(),
      cnicTEController = TextEditingController(),
      dobTEController = TextEditingController(),
      doiTEController = TextEditingController(),
      doeTEController = TextEditingController();

  Future<void> scanCnic(ImageSource imageSource) async {
    /// you will need to pass one argument of "ImageSource" as shown here
    CnicModel? cnicModel = await CnicScanner().scanImage(imageSource: imageSource);
    if (cnicModel.cnicNumber.isNotEmpty) {
      setState(() {
        showCnicDetails = true;
        _cnicModel = cnicModel;
        nameTEController.text = _cnicModel.cnicHolderName;
        cnicTEController.text = _cnicModel.cnicNumber;
        dobTEController.text = _cnicModel.cnicHolderDateOfBirth;
        doiTEController.text = _cnicModel.cnicIssueDate;
        doeTEController.text = _cnicModel.cnicExpiryDate;
        print("Cnic model is: ");
        print(_cnicModel.toString());
      });
    }
  }

  // Handle Code Verification

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  String? myCountryCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile First'),
      ),
      body: Center(
        child: Column(
          children: [
            Gap(10),
            _circularImage(context),
            Card(
              elevation: 5,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // CNIC
                        getUploadRow(context),

                        SizedBox(height: 16.0),

                        // Phone Number

                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefix: CountryCodePicker(
                                onChanged: (value) {
                                  myCountryCode = value.dialCode;
                                  print("My Country Code ${myCountryCode}");
                                },
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: 'IT',
                                favorite: ['+92', 'PK'],
                                // optional. Shows only country name and flag
                                showCountryOnly: false,
                                // optional. Shows only country name and flag when popup is closed.
                                showOnlyCountryWhenClosed: false,
                                // optional. aligns the flag and the Text left
                                alignLeft: false,
                              ),
                              labelText: 'Phone Number',
                              hintText: 'eg. 3058431046',
                              // suffixIcon: TextButton(
                              //   child: Text(
                              //     "Verify",
                              //     style: TextStyle(
                              //         color: Colors.blue, fontWeight: FontWeight.bold),
                              //   ),
                              //   onPressed: () async{
                              //     String? phoneNumber = _phoneNumberController.text;
                              //     if(phoneNumber.startsWith("0")) {
                              //       phoneNumber = phoneNumber.substring(1);
                              //     }
                              //     phoneNumber = "$myCountryCode$phoneNumber";
                              //     print("My phone Number is $phoneNumber");
                              //     if(phoneNumber.isNotEmpty){
                              //       bool value = await nextScreenPhoneAuth(context,
                              //           PhoneAuthPage(number: phoneNumber));
                              //       if(value){
                              //         isPhoneAuthenticated = true;
                              //       }
                              //     }
                              //     // Clear the text field
                              //
                              //
                              //   },
                              // ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16.0),

                        // Verify Phone Number Button

                        // Gender Selection (Radio Buttons)
                        FormBuilderRadioGroup(
                          name: 'gender',
                          decoration: InputDecoration(
                            labelText: 'Gender',
                          ),
                          options: [
                            FormBuilderFieldOption(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            FormBuilderFieldOption(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                          ],
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your gender';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            print(value);
                          },
                        ),
                        SizedBox(height: 16.0),

                        // Profile Picture Upload

                        SizedBox(height: 16.0),

                        // User Type Selection (Dropdown)
                        FormBuilderDropdown(
                          name: 'userType',
                          decoration: InputDecoration(
                            labelText: 'User Type',
                          ),
                          items: UserType.values
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name.toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedUserType = value as UserType;
                            });
                          },
                          validator: FormBuilderValidators.required(
                            errorText: 'Please select a User Type',
                          ),
                        ),
                        SizedBox(height: 16.0),

                        Center(
                          child: myFirstButton2(
                            onPressed: () async {
                              setState(() {
                                signUpStarted = true;
                              });

                              if (_formKey.currentState!.validate()) {
                                print("0");

                                // _formKey.currentState!.save();
                                bool value = await _saveUserDetails();

                                if (value == true) {
                                  Navigator.of(context).pop(true);
                                } else {
                                  Navigator.of(context).pop(false);
                                }
                              } else {
                                print("1");
                              }
                            },
                            text: signUpStarted == false
                                ? Text(
                                    'Complete Profile',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ).tr()
                                : signUpCompleted == false
                                    ? SizedBox(
                                        width: 32.0,
                                        height: 32.0,
                                        child: new CupertinoActivityIndicator())
                                    : Text('sign up successful!',
                                            style: TextStyle(
                                                fontSize: 16, color: Colors.white))
                                        .tr(),
                          ),
                        ),

                        // Submit Button

                        // CNIC Image Upload
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool? cannotGetDetails;

  getUploadRow(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cannotGetDetails == null
            ? Container()
            : cannotGetDetails == true
                ? Text(
                    "Re-try uploading CNIC",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  )
                : Text(""),
        _cnicModel.cnicNumber.isNotEmpty
            ? Text(
                "CNIC Details",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Upload CNIC"),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await scanCnic(ImageSource.camera);
                            if (_cnicModel.cnicNumber.isEmpty) {
                              cannotGetDetails = true;
                            } else {
                              cannotGetDetails = false;
                            }
                            setState(() {
                              isLoading = false;
                            });
                          },
                          icon: Icon(Icons.camera)),
                    ],
                  ),
                ],
              ),
        _cnicModel.cnicNumber.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CNIC: ${_cnicModel.cnicNumber}"),
                  Text("DOB: ${_cnicModel.cnicHolderDateOfBirth}"),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Issue Date: ${_cnicModel.cnicIssueDate}"),
                      Text("Expiry Date: ${_cnicModel.cnicExpiryDate}"),
                    ],
                  ),
                ],
              )
            : Container(),
        _cnicModel.cnicNumber.isNotEmpty
            ? Text(
                "Note: Your details must be accurate or retry uploading image",
                style: TextStyle(fontWeight: FontWeight.bold),
              ).tr()
            : Container()
      ],
    );
  }
}
