import 'dart:io';
import 'package:crimebook/blocs/all_crime_bloc/commonWidgets/showWidgets.dart';
import 'package:crimebook/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:crimebook/blocs/getxLogics/user_logic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';

import '../../blocs/all_crime_bloc/evidence_bloc.dart';
import '../../config/firebase_config.dart';
import '../models/all_crime_models/evidence.dart';
import '../utils/buttons.dart';

class EvidenceFormScreen extends StatefulWidget {
  final String crimeId; // Pass the crime ID from the previous screen

  const EvidenceFormScreen({Key? key, required this.crimeId}) : super(key: key);

  @override
  State<EvidenceFormScreen> createState() => _EvidenceFormScreenState();
}

class _EvidenceFormScreenState extends State<EvidenceFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _picker = ImagePicker();

  // State variables

  EvidenceType? _selectedEvidenceType;
  var _description = TextEditingController();
  String? _witnessId;
  String? _testimony;

  // Speech-to-text
  late SpeechToText _speechToText;
  bool _isListening = false;
  String? _recognizedWords;

  FilePickerResult? pickedMedia;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speechToText = SpeechToText();
  }

  // Function to pick media (images, videos, documents)
  Future<void> selectMedia(EvidenceType type) async {
    _selectedEvidenceType = type;
    print("My type is: ${type.name}");
    try {
      switch (type) {
        case EvidenceType.photo:
          var pickFile = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: true, // Allow multiple selection
          );
          pickedMedia = pickFile;
          break;
        case EvidenceType.video:
          var pickFile = await FilePicker.platform.pickFiles(
            type: FileType.video,
            allowMultiple: true, // Allow multiple selection
          );
          // EvidenceTypeDetail myNewObject = EvidenceTypeDetail(type, pickFile);
          pickedMedia = pickFile;
          break;
        case EvidenceType.audio:
          var pickFile = await FilePicker.platform.pickFiles(
            type: FileType.audio,
            allowMultiple: true, // Allow multiple selection
          );
          pickedMedia = pickFile;
          break;
        case EvidenceType.document:
          var pickFile = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: true, // Allow multiple selection
          );
          pickedMedia = pickFile;
          break;
        default:
          print("nothing added");
          break;
      }
    } catch (e) {
      print('Error picking media: $e');
      return null;
    }
    return null;
  }

  // Function to upload media to Firebase Storage
  Future<List<String>> _uploadMediaToStorage() async {
    var uC = Get.find<UserLogic>();
    List<String> mediaUrls = [];
    if (pickedMedia != null) {
      for (var mediaFile in pickedMedia!.paths) {
        final file = File(mediaFile!);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('evidence')
            .child(widget.crimeId)
            .child(uC.currentUser.value!.uid!)
            .child(mediaFile
            .split('/')
            .last);
        try {
          final uploadTask = await storageRef.putFile(file);
          final downloadUrl = await uploadTask.ref.getDownloadURL();
          mediaUrls.add(downloadUrl);

          print("Urls uploaded are:");
          mediaUrls.forEach((value) {
            print(value.toString());
          });
        } catch (e) {
          print('Error uploading media: $e');
        }
      }
    }
    return mediaUrls;
  }

  // Function to save the evidence data
  Future<bool> _saveEvidence() async {
    bool dataSaved = false;
    final evidenceBloc = Provider.of<EvidenceBloc>(context, listen: false);
    if (_formKey.currentState!.validate() && pickedMedia != null) {
      print("Description is: ${_formKey.currentState!.fields['description']!.value!}");
      var mediaUrls = await _uploadMediaToStorage();
      var uC = Get.find<UserLogic>();
      print(uC.currentUser.value.toString());

      // Create the Evidence object
      final newEvidence = Evidence(
        id: Uuid().v1(),
        // Generate a unique ID
        crimeId: widget.crimeId,
        // Use the crime ID passed from the previous screen
        evidenceType: _selectedEvidenceType,
        urls: mediaUrls,
        description:_description.text,
        witnessId: uC.currentUser.value!.uid,
        testimony: _testimony,
      );

      // Save the evidence to Firestore
      await evidenceBloc.createEvidence(newEvidence);
      // Optionally navigate back to the previous screen
      // Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evidence saved successfully!')),
      );
      dataSaved = true;
    }
    if (dataSaved == true) {
      return true;
    } else {
      return false;
    }
  }

  selectMediaButtons(context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Select", style: TextStyle(color: Colors.black87)),
            Text("Clear",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Use myFirstButton instead of ElevatedButton
            myFirstButton(
              onPressed: () async {
                await selectMedia(EvidenceType.photo);
                setState(() {});
              },
              text: Text('Photos'),
            ),
            myFirstButton(
              onPressed: () async {
                await selectMedia(EvidenceType.video);
                setState(() {});
              },
              text: Text('Videos').tr(),
            ),
            myFirstButton(
              onPressed: () async {
                await selectMedia(EvidenceType.audio);
                setState(() {});
              },
              text: Text('Audio'),
            ),
            myFirstButton(
              onPressed: () async {
                await selectMedia(EvidenceType.document);
                setState(() {});
              },
              text: Text('Documents'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _rewriteDescriptionInEnglish() async {
    print("Rewrite description");
    final gemini = Gemini.instance;

    print("Rewrite description");

    if (_formKey.currentState?.fields['description'] != null) {
      print(
          "recognized is not null ${_formKey.currentState?.fields['description']
              ?.value}");

      final response = await gemini
          .streamGenerateContent(
          "This is a testimony provided by witness. Write it professionally: ${_description.text}")
          .first; // Await the first response

      print(response.output);
      setState(() {
        _description.text =response.output??'Please try again';
        _formKey.currentState?.fields['description']?.didChange(response.output);
      });
    } else {
      print("recognized is null ${_formKey.currentState?.fields['description']}");
    }
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
            _formKey.currentState?.fields['description']
                ?.didChange(result.recognizedWords); // Use didChange
          });
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
        ),
        listenFor: Duration(seconds: 40)); // Listen indefinitely
  }

  Future<void> _stopListening() async {
    setState(() {
      _isListening = false;
    });
    _speechToText.stop();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Evidence').tr(),
      ),
      body: isLoading == true
          ? showMyIndicator()
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Evidence Type Selection
                  // Display Selected Media
                  selectMediaButtons(context),
              if (pickedMedia != null)
          SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: pickedMedia!.paths.length,
            itemBuilder: (context, index) {
              var myPath = pickedMedia!.paths[index];
              if (myPath == null) return Container();

              // Extract the file name from the path
              var fileName = myPath.split('/').last;
              print(fileName);

              return Container(
                margin: EdgeInsets.only(bottom: 5), // Add margin to create space between items
                padding: EdgeInsets.symmetric(horizontal: 10), // Adjust padding for alignment
                height: 60, // Adjust height for each item
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Icon(Icons.attach_file),
                    SizedBox(width: 10), // Adjust gap between icon and text
                    Expanded(
                      child: Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),


        Stack(
        alignment: Alignment.bottomRight,
        children: [
          FormBuilderTextField(
            controller: _description,
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
                          color: _isListening
                              ? Colors.blue
                              : Colors.black87)),
                  onTap: _isListening ? _stopListening : _startListening,
                ),
                InkWell(
                    child: Container(
                        alignment: Alignment.bottomRight,
                        height: 60,
                        width: 60,
                        child: Icon(Icons.close,
                            size: 24, color: Colors.black87)),
                    onTap: () {
                      _description.clear();
                      setState(() {});
                    }),
              ],
            ),
          ),
        ],
      ),

      // Testimony
      Gap(14),
      myFirstButton(
        onPressed: _rewriteDescriptionInEnglish,
        text: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy_outlined),
            Gap(8),
            const Text('Rewrite description in English').tr(),
          ],
        ),
      ),
      const SizedBox(height: 16.0),

      // Save Button
      myFirstButton2(
        onPressed: () async {
          if (_formKey.currentState!.validate() == true) {
            _formKey.currentState!.save();
            setState(() {
              isLoading = true;
            });
            bool value = await _saveEvidence();
            setState(() {
              isLoading = false;
            });
            if (value == false) {
              // Navigator.of(context).pop(false);
              openToast(context, "Something wrong, please try again.");
            } else {
              Navigator.of(context).pop(true);
            }
          }
        },
        text: const Text('Save Evidence'),
      ),
      ],
    ),)
    ,
    )
    ,
    )
    ,
    );
  }
}

class EvidenceTypeDetail {
  EvidenceType? type;
  FilePickerResult? file;
  List<String> imageUrls = [];

  EvidenceTypeDetail(this.type, this.file);
}
