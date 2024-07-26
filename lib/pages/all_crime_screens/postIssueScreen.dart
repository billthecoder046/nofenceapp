import 'dart:developer';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:geohash_plus/geohash_plus.dart' as geoHash;
import 'package:intl/intl.dart';
import 'package:nofence/blocs/all_crime_bloc/crime_feedback_bloc.dart';
import 'package:nofence/blocs/all_crime_bloc/witness_bloc.dart';
import 'package:nofence/blocs/sign_in_bloc.dart';
import 'package:nofence/models/all_crime_models/crime.dart';
import 'package:nofence/models/all_crime_models/crimefeedback.dart';
import 'package:nofence/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker  Import multi_image_picker
import 'package:speech_to_text/speech_to_text.dart';
import '../../blocs/all_crime_bloc/ciminal_bloc.dart';
import '../../blocs/all_crime_bloc/crime_bloc.dart';
import '../../blocs/all_crime_bloc/evidence_bloc.dart';
import '../../blocs/all_crime_bloc/location_bloc.dart';
import '../../blocs/justice_bloc.dart';
import '../../config/config.dart';
import '../../config/firebase_config.dart';
import '../../models/all_crime_models/addCriminal.dart';
import '../../models/all_crime_models/criminals.dart';
import '../../models/all_crime_models/evidence.dart';
import '../../models/all_crime_models/judgeRemark.dart';
import '../../models/all_crime_models/witness.dart';
import '../../utils/buttons.dart';
import '../../utils/next_screen.dart'; // Import GeoFirestore

class CrimeFormScreen extends StatefulWidget {
  const CrimeFormScreen({Key? key}) : super(key: key);

  @override
  State<CrimeFormScreen> createState() => _CrimeFormScreenState();
}

class _CrimeFormScreenState extends State<CrimeFormScreen> {
  var _locationController = TextEditingController();

  LatLng? _selectedLocation;
  bool _isLoadingJudges = true;
  List<Judge> availableJudges = [];
  List<String> criminalIds = [];
  List<String> evidenceMediaUrls = [];
  var newCrime = Crime();
  WitnessType? _selectedWitnessType = WitnessType.yes;

  bool isFormValidated = true;

  // For image/video selection
  List<XFile> _selectedMedia = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isGettingLocation = false;
  bool isSavingCriminal = false;
  bool isSavingCrime = false;

  // Speech-to-text
  late SpeechToText _speechToText;
  bool _isListening = false;
  String? _recognizedWords;
  final _formKeyCrime = GlobalKey<FormBuilderState>();

  // Future to handle image and video selection
  Future<void> _selectMedia() async {
    try {
      // Use pickMultiImage() for both images and videos
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

  // Function to upload media to Firebase Storage
  Future<List<String>> _uploadMediaToStorage(List<XFile> mediaFiles) async {
    List<String> mediaUrls = [];

    for (var mediaFile in mediaFiles) {
      final file = File(mediaFile.path);
      final storageRef =
      FirebaseStorage.instance.ref().child('crimes').child(mediaFile.name);
      try {
        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        mediaUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading media: $e');
      }
    }

    return mediaUrls;
  }

  // Function to get the user's current location (for the crime location)

  // Function to fetch available judges from the bloc
  Future<void> _fetchAvailableJudges(BuildContext context) async {
    final justiceBloc = Provider.of<JusticeBloc>(context, listen: false);
    try {
      await justiceBloc.fetchAllJudges();
      setState(() {
        _isLoadingJudges = false;
        availableJudges =
            justiceBloc.judges.where((judge) => judge.isAssigned == false).toList();
      });
    } catch (e) {
      print('Error fetching judges: $e');
    }
  }

  // Function to fetch available criminals from the bloc and all related data

  // Function to filter criminals based on search

  // Function to create a new criminal

  @override
  void initState() {
    super.initState();
    _fetchAvailableJudges(context);

    _speechToText = SpeechToText();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    _speechToText = SpeechToText();
    print('0');
    if (!await _speechToText.initialize()) {
      print('Speech-to-text not available');
      return;
    }

    setState(() {
      _isListening = true;
    });
    print('0');
    _speechToText.listen(
        onResult: (result) {
          print('0Listen');
          setState(() {
            _formKeyCrime.currentState?.fields['description']
                ?.didChange(result.recognizedWords); // Use didChange
          });
        },
        listenFor: null); // Listen indefinitely
  }

  Future<void> _stopListening() async {
    setState(() {
      _isListening = false;
    });
    _speechToText.stop();
  }

  Future<Crime> saveCrime() async     {
    if (_formKeyCrime.currentState!.validate() && _selectedLocation != null) {
      final formData = _formKeyCrime.currentState!.value;
      var uid = Uuid();
      String crimeId = uid.v1();
      String crimeFeedbackId = uid.v1();
      newCrime = Crime(
          id: crimeId,
          crimeCategory: formData['crimeCategory'],
          // Use the 'location' field for GeoFirestore
          location: {
            'g': '', // Geohash will be calculated later
            'l': [_selectedLocation!.latitude, _selectedLocation!.longitude],
          },
          conclusion: '',
          date: formData['date'],
          userDescription: formData['description'],
          userTitle: formData['title'],
          assignedJudgeId: formData['assignedJudgeId'] ?? '',
          criminalIds: formData['criminalIds'] ?? [],
          feedback: crimeFeedbackId);
      // Calculate Geohash
      var myGeoPoint = geoHash.GeoHash.encode(
          newCrime.location!['l'][0], newCrime.location!['l'][1],
          precision: 11);
      newCrime.location!['g'] = myGeoPoint.hash;

      // Upload media to Firebase Storage
      evidenceMediaUrls = await _uploadMediaToStorage(_selectedMedia);

      print("My list of Crime IDS ");
      criminalIds.forEach((element) {
        print("Shayan Idfs: ${element}");
      });
      newCrime.criminalIds = [];
      newCrime.criminalIds!.addAll(criminalIds);

      // Create the crime and update associated data
    }
    return newCrime;
  }

  showAnimatedText(context) {
    return SizedBox(
      width: 250.0,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 20.0,
        ),
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText('Please wait...'),
            TypewriterAnimatedText('Crime is being analyzed'),
            TypewriterAnimatedText('Will be added Soon...'),
          ],
          onTap: () {
            print("Tap Event");
          },
        ),
      ),
    );
  }

  Widget crimeDetails(context, LocationBloc locationBloc) {
    return FormBuilder(
      key: _formKeyCrime,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Add Details of Crime',
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).secondaryHeaderColor,
                  fontWeight: FontWeight.bold),
            ).tr(),
          ),
          Card(
            elevation: 8.0,
            child: Container(
              height: MediaQuery.of(context).size.height * 1,
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: isSavingCrime
                  ? showAnimatedText(context)
                  : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Crime Type
                  FormBuilderRadioGroup(
                    name: 'witnessType',
                    decoration: const InputDecoration(
                      labelText: 'Post it as',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedWitnessType = value;
                      });
                    },
                    options: WitnessType.values
                        .map((type) => FormBuilderFieldOption(
                      value: type,
                      child: Text(type.name
                          .toUpperCase()
                          .tr()), // Use tr() for translation
                    ))
                        .toList(),
                  ),
                  FormBuilderDropdown(
                    name: 'crimeCategory',
                    decoration: const InputDecoration(
                      labelText: 'Crime Category',
                    ),
                    // allowClear: true,
                    items: CrimeType.values
                        .map((crimeType) => DropdownMenuItem(
                      value: crimeType,
                      child: Text(crimeType.name),
                    ))
                        .toList(),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select a crime category',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Title
                  FormBuilderTextField(
                    name: 'title',
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'What Happened?',
                    ),
                    maxLines: 1,
                    validator: FormBuilderValidators.required(
                      errorText: 'Please provide a title',
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Crime Type

                  // Location (using TextField and Geolocator)
                  FormBuilderTextField(
                    name: 'location',
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                    ),
                    readOnly: false,
                  ),
                  const SizedBox(height: 16.0),

                  isGettingLocation
                      ? SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: new CupertinoActivityIndicator())
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      myFirstButton(
                          text: const Text('Get Current Location'),
                          onPressed: () async {
                            setState(() {
                              isGettingLocation = true;
                            });
                            Map<String, dynamic> location = await locationBloc
                                .getCurrentLocation(context);
                            print(location['controller'].runtimeType);
                            print(location['loc'].runtimeType);
                            _selectedLocation = location['loc'];
                            _locationController = location['controller'];
                            setState(() {
                              isGettingLocation = false;
                            });
                          }),
                      myFirstButton(
                          text: const Text('Add Criminal'),
                          onPressed: () async {
                            try {
                              setState(() {
                                isGettingLocation = true;
                              });
                              String? criminalId =
                              await nextScreenCriminalDetails(
                                  context, CriminalDetails());
                              if (criminalId != null) {
                                print("idrees doc id is: ${criminalId}");
                                openToast(context,
                                    'Criminal is added successfully');
                                criminalIds.add(criminalId);
                              } else {
                                print("Criminal Id is null");
                              }

                              setState(() {
                                isGettingLocation = false;
                              });
                            } on Exception catch (e) {
                              print(e.toString());
                              setState(() {
                                isGettingLocation = false;
                              });
                              // TODO
                            }
                          }),
                    ],
                  ),

                  SizedBox(height: 16.0),

                  // Date and Time
                  FormBuilderDateTimePicker(
                    name: 'date',
                    decoration: const InputDecoration(
                      labelText: 'Date and Time',
                    ),
                    inputType: InputType.both,
                    format: DateFormat('yyyy-MM-dd HH:mm'),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select a date and time',
                    ),
                  ),
                  // Description
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      FormBuilderTextField(
                        name: 'description',
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Provide details about the crime.',
                        ),
                        maxLines: 4,
                        validator: FormBuilderValidators.required(
                          errorText: 'Please provide a description',
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              child: Container(
                                  alignment: Alignment.bottomRight,
                                  height: 60,
                                  width: 60,
                                  child: Icon(Icons.mic,
                                      size: _isListening ? 28 : 24,
                                      color:
                                      _isListening ? Colors.blue : Colors.black87)),
                              onTap: _isListening ? _stopListening : _startListening,
                            ),
                            InkWell(
                                child: Container(
                                    alignment: Alignment.bottomRight,
                                    height: 60,
                                    width: 60,
                                    child: Icon(Icons.close,
                                        size: _isListening ? 28 : 24,
                                        color:
                                        _isListening ? Colors.blue : Colors.black87)),
                                onTap: (){
                                  _formKeyCrime.currentState?.fields['description']?.reset();
                                  setState(() {

                                  });
                                }
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(14),
                  myFirstButton(
                    onPressed: _rewriteDescriptionInEnglish,
                    text: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.smart_toy_outlined),
                        Gap(8),
                        const Text('Rewrite Description using AI'),
                      ],
                    ),
                  ),
                  Gap(14),

                  InkWell(
                    onTap: () {
                      _selectMedia();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.insert_page_break,
                          color: Colors.blue,
                        ),
                        Gap(10),
                        Text(
                          "${_selectedMedia.isNotEmpty ? 'Evidence Selected' : 'Select Evidence (Images/Videos)'}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),

                  // Display Selected Media
                  if (_selectedMedia.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var mediaFile in _selectedMedia)
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              height: 100,
                              width: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(mediaFile.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _rewriteDescriptionInEnglish() async {
    print("Rewrite description");
    final gemini = Gemini.instance;

    print("Rewrite description");

    if (_formKeyCrime.currentState?.fields['description'] != null) {
      print(
          "recognized is not null ${_formKeyCrime.currentState?.fields['description']?.value}");

      final response = await gemini.streamGenerateContent(
          "This is an crime reporting text field. A user input his issue in the field and wants you to write it again in a more better way to express his concerns in English language: ${_formKeyCrime.currentState?.fields['description']?.value}").first; // Await the first response

      print(response.output);
      setState(() {
        _formKeyCrime.currentState?.fields['description']?.didChange(response.output);
      });
    } else {
      print("recognized is null ${_formKeyCrime.currentState?.fields['description']}");
    }
  }
  @override
  Widget build(BuildContext context) {
    final criminalBloc = Provider.of<CriminalBloc>(context, listen: false);
    final crimeBloc = Provider.of<CrimeBloc>(context, listen: false);
    final locationBloc = Provider.of<LocationBloc>(context, listen: false);
    final justiceBloc = Provider.of<JusticeBloc>(context, listen: false);
    // ... other code ...

    return Scaffold(
      appBar: AppBar(
        title: Text('Report Crime').tr(),
        actions: [
          isLoading
              ? SizedBox(
              width: 32.0, height: 32.0, child: new CupertinoActivityIndicator())
              : InkWell(
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 16,
                  ),
                  Gap(5),
                  Text(
                    "Clear",
                    style: TextStyle(color: Colors.red),
                  ),
                  Gap(15),
                ],
              ),
              onTap: () async {
                _selectedMedia = [];
                _locationController.clear();
                setState(() {
                  isLoading = true;
                });
                _formKeyCrime.currentState!.reset();
                newCrime = Crime();
                setState(() {
                  isLoading = false;
                });
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 1.1,
          child: crimeDetails(context, locationBloc),
        ),
      ),
      floatingActionButton: myFirstButton2(
        text: const Text('Submit'),
        onPressed: () async {

          try {
            setState(() {
              isSavingCrime = true;
            });
            _formKeyCrime.currentState!.save();
            print("My form: ${_formKeyCrime.currentState!.value}");
            //My bloc initialized here
            final crimeBloc = Provider.of<CrimeBloc>(context, listen: false);
            final evidenceBloc = Provider.of<EvidenceBloc>(context, listen: false);
            final witnessBloc = Provider.of<WitnessBloc>(context, listen: false);
            final signInBloc = Provider.of<SignInBloc>(context, listen: false);
            final crimeFeedBackBloc =
            Provider.of<CrimeFeedbackBloc>(context, listen: false);

            //Rest code
            print("Crime Deetails: ${newCrime.toJSON()}");
            Crime myCrimeObj = await saveCrime();
            print("My crime Obje ${myCrimeObj.toJSON()}");

            ///Save evidence
            String evidenceId = Uuid().v1();
            Evidence newEvidence = Evidence(
              id: evidenceId,
              crimeId: myCrimeObj.id,
              witnessId: FirebaseAuth.instance.currentUser!.uid,
              urls: evidenceMediaUrls,
            );

            if (myCrimeObj.evidence != null) {
              myCrimeObj.evidence!.add(newEvidence.id!);
            }else{
              myCrimeObj.evidence = [];
              myCrimeObj.evidence!.add(newEvidence.id!);
            }
            await evidenceBloc.createEvidence(newEvidence);

            String witnessId = FirebaseAuth.instance.currentUser!.uid;
            Witness newWitness = Witness(
              id: witnessId,
              name: signInBloc.name,
            );
            if(newWitness.crimeId == null){
              newWitness.crimeId = [];
              newWitness.crimeId!.add(myCrimeObj.id!);
            }else{
              newWitness.crimeId!.add(myCrimeObj.id!);
            }
            await witnessBloc.createWitness(newWitness);


            //Create CrimeOBJ
            if (myCrimeObj.witnesses != null) {
              myCrimeObj.witnesses!.add(witnessId);
            }


            if(myCrimeObj.evidence == null){
              myCrimeObj.evidence= [];
              myCrimeObj.evidence!.add(newEvidence.id!);
            }else{
              myCrimeObj.evidence!.add(newEvidence.id!);
            }
            if(myCrimeObj.witnesses == null){
              myCrimeObj.witnesses= [];
              myCrimeObj.witnesses!.add(newWitness.id!);
            }else{
              myCrimeObj.witnesses!.add(newWitness.id!);
            }

            myCrimeObj.judgeRemarks = [];
            await crimeBloc.createCrime(myCrimeObj).then((_) {
              // Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Crime report submitted!'),
                ),
              );
            });
            var uid = Uuid();
            var crimeFeedbackId = uid.v1();
            CrimeFeedback crimeFeedback = CrimeFeedback(
              id: crimeFeedbackId,
              crimeId: newCrime.id,
            );
            await crimeFeedBackBloc.createCrimeFeedback(crimeFeedback);
            setState(() {
              isSavingCrime = false;
            });
          } on Exception catch (e) {
            print(e.toString());
            // TODO
          } finally {
            setState(() {
              isSavingCrime = false;
            });
            Navigator.of(context).pop();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}