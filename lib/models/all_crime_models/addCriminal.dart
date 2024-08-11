import 'dart:io';
import 'package:crimebook/blocs/all_crime_bloc/commonWidgets/showWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart' hide Trans;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../blocs/all_crime_bloc/ciminal_bloc.dart';
import '../../utils/buttons.dart';
import 'criminals.dart';


enum GenderType {
  Male, // Anonymous witness
  Female, // Identified witness
}
class CriminalDetails extends StatefulWidget {
  CriminalDetails({super.key});

  @override
  State<CriminalDetails> createState() => _CriminalDetailsState();
}

class _CriminalDetailsState extends State<CriminalDetails> {
  final _formKeyCriminal = GlobalKey<FormBuilderState>();
  var showC = Get.put(ShowWidgets());

  // Criminal related state
  final _criminalSearchController = TextEditingController();
  List<Criminal> _filteredCriminals = [];
  bool _isLoadingCriminals = false;

  List<String> crimeMediaUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isGettingLocation = false;
  GenderType? _selectedGenderType;
  bool isSavingCriminal = false;

  void _filterCriminals(String query) {
    final criminalBloc = Provider.of<CriminalBloc>(context, listen: false);
    setState(() {
      _filteredCriminals = criminalBloc.criminals.where((criminal) {
        final name = criminal.name?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _fetchCriminals(BuildContext context) async {
    final criminalBloc = Provider.of<CriminalBloc>(context, listen: false);
    _isLoadingCriminals = true;
    try {
      await criminalBloc.fetchAllCriminals();
      setState(() {
        _filteredCriminals = criminalBloc.criminals;
        _isLoadingCriminals = false;
      });
    } catch (e) {
      print('Error fetching criminals: $e');
    }
  }

  Future<void> _saveCriminal() async {
    final formCriminal = _formKeyCriminal.currentState!.value;
    final criminalBloc = Provider.of<CriminalBloc>(context, listen: false);
    // Create new Criminal object
    var uid = Uuid();
    final newCriminal = Criminal(
      id: uid.v1(),
      name: formCriminal['name'],
      nic: formCriminal['nic'],
      nickName: formCriminal['nickName'],
      addedBy: FirebaseAuth.instance.currentUser!.uid,
      gender: _selectedGenderType!.name
    );

    // Upload Images to Firebase Storage
    for (var mediaCFile in showC.selectedCriminalPics!) {
      final file = File(mediaCFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('Criminals')
          .child('${newCriminal.id}')
          .child(mediaCFile.name);
      try {
        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        crimeMediaUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading media: $e');
      }
    }
    crimeMediaUrls.forEach((element) {
      newCriminal.imageUrls ??= [];
      newCriminal.imageUrls!.add(element);
      print("URL CXRIMENAL IMAGE");
      print(element);
    });

    // Save the new Criminal to Firestore
    await criminalBloc.createCriminal(newCriminal);
    Navigator.of(context).pop(newCriminal.id);
  }

  Future<void> _selectCMedia() async {
    try {
      final List<XFile>? pickedMedia = await _picker.pickMultiImage(imageQuality: 50);
      if (pickedMedia != null && pickedMedia.isNotEmpty) {
        setState(() {
          showC.selectedCriminalPics.addAll(pickedMedia) ;
        });
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicController = TextEditingController();
  final TextEditingController aliasController = TextEditingController();

  Future<void> _selectMediaFromCamera() async {
    try {
      // Use pickMultiImage() for both images and videos
      final XFile? pickedMedia = await _picker.pickImage(imageQuality: 50, source: ImageSource.camera);
      if (pickedMedia != null) {
        setState(() {
          showC.selectedCriminalPics.value = [];
          showC.selectedCriminalPics.add(pickedMedia);
        });
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  // Function to upload media to Firebase Storage

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCriminals(context);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Criminal').tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: FormBuilder(
          key: _formKeyCriminal,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Add Details of Criminal',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).secondaryHeaderColor,
                        fontWeight: FontWeight.bold),
                  ).tr(),
                ),

                Card(
                  elevation: 8.0,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 10,
                            ),
                            margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              border: Border.all(color: Colors.grey[400]!, width: 0.5),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search),
                                SizedBox(width: 8),
                                // Optional spacing between icon and text
                                Expanded(
                                  child: TextField(
                                    controller: _criminalSearchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search Criminals',
                                      // Remove 'Search' from hint text
                                      border: InputBorder.none,
                                    ),
                                    onChanged: _filterCriminals,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isLoadingCriminals)
                            SizedBox(
                                width: 32.0,
                                height: 32.0,
                                child: new CupertinoActivityIndicator())
                          else
                            SizedBox(
                              height: 150,
                              child: _filteredCriminals.isEmpty
                                  ? Center(child: Text('No Criminals Found').tr())
                                  : ListView.builder(
                                itemCount: _filteredCriminals.length,
                                itemBuilder: (context, index) {
                                  final criminal = _filteredCriminals[index];
                                  return ListTile(
                                    title: Text(criminal.name ?? 'Unknown'),
                                    trailing: Checkbox(
                                      value: _formKeyCriminal.currentState
                                          ?.fields['criminalIds']?.value !=
                                          null
                                          ? (_formKeyCriminal
                                          .currentState
                                          ?.fields['criminalIds']
                                          ?.value as List)
                                          .contains(criminal.id)
                                          : false,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _formKeyCriminal.currentState
                                                ?.fields['criminalIds'] =
                                            ((_formKeyCriminal
                                                .currentState
                                                ?.fields['criminalIds']
                                                ?.value as List?) ??
                                                [])
                                            as FormBuilderFieldState<
                                                FormBuilderField, dynamic>;
                                            _formKeyCriminal.currentState
                                                ?.fields['criminalIds']?.value
                                                .add(criminal.id);
                                          } else {
                                            _formKeyCriminal.currentState
                                                ?.fields['criminalIds'] =
                                            ((_formKeyCriminal
                                                .currentState
                                                ?.fields['criminalIds']
                                                ?.value as List?) ??
                                                [])
                                            as FormBuilderFieldState<
                                                FormBuilderField, dynamic>;
                                            _formKeyCriminal.currentState
                                                ?.fields['criminalIds']?.value
                                                .remove(criminal.id);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                      selectMedia(context),
                      const SizedBox(height: 16.0),

                      isSavingCriminal
                          ? SizedBox(
                          width: 32.0,
                          height: 32.0,
                          child: new CupertinoActivityIndicator())
                          : Container(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormBuilderTextField(
                              name: 'name',
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                hintText: 'Enter Criminal Name',
                              ),
                              validator: FormBuilderValidators.required(
                                errorText: 'Please enter a name',
                              ),
                            ),
                            SizedBox(height: 10),
                            FormBuilderTextField(
                              name: 'nic',
                              controller: nicController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'NIC',
                                hintText: 'Enter Criminal NIC',
                              ),
                            ),
                            SizedBox(height: 10),
                            FormBuilderTextField(
                              name: 'nickName',
                              controller: aliasController,
                              decoration: InputDecoration(
                                labelText: 'Nick Name',
                                hintText: 'Enter Criminal nickName',
                              ),
                            ),
                            FormBuilderRadioGroup(
                              name: 'gender',
                              decoration: InputDecoration(
                                labelText: 'Select Gender'.tr(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGenderType = value;
                                });
                              },
                              options: GenderType.values
                                  .map((type) => FormBuilderFieldOption(
                                value: type,
                                child: Text(type.name
                                    .toUpperCase()), // Use tr() for translation
                              ))
                                  .toList(),
                              validator: FormBuilderValidators.required(
                                errorText: "Must select the gender"
                              ),
                            ),


                            SizedBox(height: 10),
                            if (showC.selectedCriminalPics.isNotEmpty)
                              showC.showImagesHorizontally(context),
                            savingButtons(context)
                          ],
                        ),
                      ),

                      // Add New Criminal Button
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  savingButtons(context){
    return Column(
      children: [
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            myFirstButton(
              onPressed: () => _formKeyCriminal.currentState!.reset(),
              text: Text('Clear').tr(),
            ),
            myFirstButton(
              onPressed: () => Navigator.of(context).pop(),
              text: Text('Cancel').tr(),
            ),
            myFirstButton(
              onPressed: () async {
                setState(() {
                  isSavingCriminal = true;
                });
                if (_formKeyCriminal.currentState!.validate()) {
                  _formKeyCriminal.currentState!.save();
                  await _saveCriminal();
                }
                setState(() {
                  isSavingCriminal = false;
                });
              },
              text: Text('Save').tr(),
            ),
          ],
        )
      ],
    );
  }
  selectMedia(context){
    return  Container(
      padding: EdgeInsets.only(left: 12,right: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${showC.selectedCriminalPics.isNotEmpty ? 'Images Selected'.tr() : 'Select Criminal Images (if Any)'.tr()}"),
              showC.selectedCriminalPics.isNotEmpty?TextButton(child:Text('Delete All'.tr() ,style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),), onPressed: (){
                setState(() {
                  showC.selectedCriminalPics.clear();
                });
              }, ):Container()
            ],
          ),
          isLoading
              ? SizedBox(
              width: 32.0,
              height: 32.0,
              child: new CupertinoActivityIndicator())
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              myFirstButton(
                text: Row(
                    children: [
                      Icon(Icons.folder,size: 18,color: Colors.white,),Gap(10),
                      Text('Gallery'.tr())
                    ]),

                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  await _selectCMedia();
                  setState(() {
                    isLoading = false;
                  });
                },
              ),
              myFirstButton(
                text:  Row(
                    children: [
                      Icon(Icons.camera,size: 18,color: Colors.white,),Gap(10),
                      Text('Camera').tr()
                    ]),
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  await _selectMediaFromCamera();
                  setState(() {
                    isLoading = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}