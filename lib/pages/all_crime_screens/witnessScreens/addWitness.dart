import 'dart:io';
import 'package:crimebook/blocs/all_crime_bloc/commonWidgets/showWidgets.dart';
import 'package:crimebook/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart' hide Trans;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:crimebook/blocs/getxLogics/user_logic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';

import '../../../blocs/all_crime_bloc/evidence_bloc.dart';
import '../../../config/firebase_config.dart';
import '../../../blocs/all_crime_bloc/witness_bloc.dart';
import '../../../blocs/all_crime_bloc/crime_bloc.dart';
import '../../../models/all_crime_models/addCriminal.dart';
import '../../../models/all_crime_models/evidence.dart';
import '../../../models/all_crime_models/witness.dart';
import '../../../utils/buttons.dart'; // Import CrimeBloc

class WitnessFormScreen extends StatefulWidget {
  final String crimeId;
  final List<String> witnessesList;
  final List<String> evidenceList;

  const WitnessFormScreen({Key? key, required this.crimeId, required this.witnessesList, required this.evidenceList}) : super(key: key);

  @override
  State<WitnessFormScreen> createState() => _WitnessFormScreenState();
}

class _WitnessFormScreenState extends State<WitnessFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  var showC = Get.put(ShowWidgets());
  final ImagePicker _picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Witness related state
  final _witnessSearchController = TextEditingController();
  List<Witness> _filteredWitnesses = [];
  bool _isLoadingWitnesses = false;

  List<String> witnessMediaUrls = [];
  bool isLoading = false;
  bool isGettingLocation = false;
  GenderType? _selectedGenderType;
  bool isSavingWitness = false;
  List<String> imageUrls = []; // Initialize as an empty list

  // Evidence related state
  EvidenceType? _selectedEvidenceType;
  var _evidenceDescription = TextEditingController();
  FilePickerResult? pickedMedia;
  bool isSavingEvidence = false;
  List<String> evidenceUrls = []; // Initialize as an empty list

  void _filterWitnesses(String query) {
    final witnessBloc = Provider.of<WitnessBloc>(context, listen: false);
    setState(() {
      _filteredWitnesses = witnessBloc.witnesses.where((witness) {
        final name = witness.name?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _fetchWitnesses(BuildContext context) async {
    final witnessBloc = Provider.of<WitnessBloc>(context, listen: false);
    _isLoadingWitnesses = true;
    try {
      await witnessBloc.fetchAllWitnesses();
      setState(() {
        _filteredWitnesses = witnessBloc.witnesses;
        _isLoadingWitnesses = false;
      });
    } catch (e) {
      print('Error fetching witnesses: $e');
    }
  }

  Future<void> _saveWitness() async {
    final formWitness = _formKey.currentState!.value;
    final witnessBloc = Provider.of<WitnessBloc>(context, listen: false);
    final crimeBloc = Provider.of<CrimeBloc>(context, listen: false);
    // Create new Witness object
    var uid = Uuid();
    String newWitnessId = uid.v1();
    String? evidenceId ;

    // Save Evidence for the witness
    if (_formKeyEvidence.currentState!.validate() && pickedMedia != null) {
      final formEvidence = _formKeyEvidence.currentState!.value;
      final evidenceBloc = Provider.of<EvidenceBloc>(context, listen: false);
      var mediaUrls = await _uploadMediaToStorageEvidence();

      // Create the Evidence object
      final newEvidence = Evidence(
        id: Uuid().v1(),
        crimeId: widget.crimeId,
        evidenceType: _selectedEvidenceType,
        urls: mediaUrls,
        description: formEvidence['description'],
        witnessId: newWitnessId, // Associate evidence with the new witness
      );

      // Save the new Evidence to Firestore
      evidenceId = await evidenceBloc.createEvidence(newEvidence);
    }
    evidenceUrls.add(evidenceId!);



    //then witness
    final newWitness = Witness(
      id: newWitnessId,
      crimeId: [widget.crimeId],
      name: formWitness['name'],
      cnic: formWitness['cnic'],
      mobileNumber: formWitness['mobileNumber'],
      profilePicUrl: imageUrls.isEmpty ? null : imageUrls[0],
      evidenceIds: evidenceUrls
    );

    // Upload Images to Firebase Storage
    for (var mediaCFile in showC.selectedWitnessPics) {
      final file = File(mediaCFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('Witnesses')
          .child('${widget.crimeId}')
          .child('${newWitness.id}')
          .child(mediaCFile.name);
      try {
        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        witnessMediaUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading media: $e');
      }
    }
    witnessMediaUrls.forEach((element) {
      newWitness.profilePicUrl ??= '';
      newWitness.profilePicUrl = element;
      print("URL WITNESS IMAGE");
      print(element);
    });

    // Save the new Witness to Firestore
    print("Witnesss in process of adding");
      await witnessBloc.createWitness(newWitness);

    // Update the crime's witnesses
    if (newWitnessId != null) {
      await crimeBloc.updateCrimeWitnesses(widget.crimeId, [
        ...widget.witnessesList,
        newWitnessId, // Add the new witness ID
      ]);
    }
    if (newWitnessId != null) {
      await crimeBloc.updateCrimeEvidences(widget.crimeId, [
        ...widget.evidenceList,
        evidenceId, // Add the new witness ID
      ]);
    }

    Navigator.of(context).pop(newWitness.id);
  }

  // Media Selection for Evidence
  Future<void> selectMediaEvidence(EvidenceType type) async {
    _selectedEvidenceType = type;
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

  // Upload Evidence Media to Firebase Storage
  Future<List<String>> _uploadMediaToStorageEvidence() async {
    List<String> mediaUrls = [];
    if (pickedMedia != null) {
      for (var mediaFile in pickedMedia!.paths) {
        final file = File(mediaFile!);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('evidence')
            .child(widget.crimeId)
            .child('${widget.crimeId}')
            .child(mediaFile
            .split('/')
            .last);
        try {
          final uploadTask = await storageRef.putFile(file);
          final downloadUrl = await uploadTask.ref.getDownloadURL();
          mediaUrls.add(downloadUrl);
        } catch (e) {
          print('Error uploading media: $e');
        }
      }
    }
    return mediaUrls;
  }

  // Function to Clear Evidence Media
  void clearEvidenceMedia() {
    setState(() {
      pickedMedia = null;
      evidenceUrls.clear();
    });
  }

  Future<void> _selectWMedia() async {
    try {
      final List<XFile>? pickedMedia = await _picker.pickMultiImage(imageQuality: 50);
      if (pickedMedia != null && pickedMedia.isNotEmpty) {
        setState(() {
          showC.selectedWitnessPics.addAll(pickedMedia);
          imageUrls.addAll(pickedMedia.map((e) => e.path).toList()); // Update imageUrls with paths
        });
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  Future<void> _selectMediaFromCamera() async {
    try {
      // Use pickMultiImage() for both images and videos
      final XFile? pickedMedia = await _picker.pickImage(imageQuality: 50, source: ImageSource.camera);
      if (pickedMedia != null) {
        setState(() {
          showC.selectedWitnessPics.value = [];
          showC.selectedWitnessPics.add(pickedMedia);
          imageUrls = [pickedMedia.path]; // Update imageUrls with the path
        });
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  // Function to upload media to Firebase Storage
  existingWitness(context){
    return  Column(
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
                  controller: _witnessSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search Witnesses',
                    // Remove 'Search' from hint text
                    border: InputBorder.none,
                  ),
                  onChanged: _filterWitnesses,
                ),
              ),
            ],
          ),
        ),
        if (_isLoadingWitnesses)
          SizedBox(
              width: 32.0,
              height: 32.0,
              child: new CupertinoActivityIndicator())
        else
          SizedBox(
            height: 150,
            child: _filteredWitnesses.isEmpty
                ? Center(child: Text('No Witnesses Found').tr())
                : ListView.builder(
              itemCount: _filteredWitnesses.length,
              itemBuilder: (context, index) {
                final witness = _filteredWitnesses[index];
                return ListTile(
                  title: Text(witness.name ?? 'Unknown'),
                  trailing: Checkbox(
                    value: _formKey.currentState
                        ?.fields['witnessIds']
                        ?.value !=
                        null
                        ? (_formKey.currentState?.fields[
                    'witnessIds']?.value as List)
                        .contains(witness.id)
                        : false,
                    onChanged: (value) {
                      print('nli  ${_formKey.currentState?.fields[
                      'witnessIds']}');
                      final witnessIdsField =
                      _formKey.currentState?.fields[
                      'witnessIds']; // Get the FormBuilderFieldState
                      if (witnessIdsField != null) {
                        if (value == true) {
                          witnessIdsField.didChange(
                              [
                                ...witnessIdsField.value,
                                witness.id // Add witness.id to the list
                              ]
                          );
                        } else {
                          witnessIdsField.didChange(
                              witnessIdsField.value
                                  .where((id) => id != witness.id)
                                  .toList() // Remove witness.id from the list
                          );
                        }
                        setState(() {});
                      }
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchWitnesses(context);
  }

  final GlobalKey<FormBuilderState> _formKeyEvidence = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Witness').tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Add Details of Witness',
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
                      //existingWitness(context)
                      SizedBox(height: 10),
                      selectMedia(context),
                      const SizedBox(height: 16.0),

                      isSavingWitness
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
                                hintText: 'Enter Witness Name',
                              ),
                              validator: FormBuilderValidators.required(
                                errorText: 'Please enter a name',
                              ),
                            ),
                            SizedBox(height: 10),
                            FormBuilderTextField(
                              name: 'cnic',
                              controller: cnicController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'CNIC',
                                hintText: 'Enter Witness CNIC',
                              ),
                            ),
                            SizedBox(height: 10),
                            FormBuilderTextField(
                              name: 'mobileNumber',
                              controller: mobileNumberController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Mobile Number',
                                hintText: 'Enter Witness Mobile Number',
                              ),
                            ),
                            SizedBox(height: 10),
                            FormBuilderTextField(
                              name: 'description',
                              controller: descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                hintText: 'Enter Witness Description',
                              ),
                            ),

                            SizedBox(height: 10),
                            if (showC.selectedWitnessPics.isNotEmpty)
                              showC.showImagesHorizontally(context),

                          ],
                        ),
                      ),
                      FormBuilder(
                        key: _formKeyEvidence,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Evidence Type Selection
                            selectMediaButtonsEvidence(context),
                            // Display Selected Media for Evidence
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
                            // Description for Evidence
                            FormBuilderTextField(
                              controller: _evidenceDescription,
                              name: 'description',
                              decoration: const InputDecoration(
                                labelText: 'Evidence Description',
                                hintText: 'Provide details about the evidence.',
                              ),
                              maxLines: 4,
                              validator: FormBuilderValidators.required(
                                errorText: 'Please provide a description',
                              ),
                            ),
                          ],
                        ),
                      ),
                      savingButtons(context)

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
              onPressed: () => _formKey.currentState!.reset(),
              text: Text('Clear').tr(),
            ),
            myFirstButton(
              onPressed: () => Navigator.of(context).pop(),
              text: Text('Cancel').tr(),
            ),
            myFirstButton(
              onPressed: () async {
                setState(() {
                  isSavingWitness = true;
                });
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  await _saveWitness();
                }
                setState(() {
                  isSavingWitness = false;
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
              Text("${showC.selectedWitnessPics.isNotEmpty ? 'Images Selected' : 'Select Witness Images (if Any)'}"),
              showC.selectedWitnessPics.isNotEmpty?TextButton(child:Text('Delete All' ,style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),), onPressed: (){
                setState(() {
                  showC.selectedWitnessPics.clear();
                  imageUrls.clear(); // Clear the imageUrls list
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
                      Text('Gallery')
                    ]),

                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  await _selectWMedia();
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

  // Media Selection Buttons for Evidence
  selectMediaButtonsEvidence(context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Select Evidence", style: TextStyle(color: Colors.black87)),
            TextButton(
              onPressed: clearEvidenceMedia, // Call clearEvidenceMedia to clear evidence
              child: Text("Clear", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            myFirstButton(
              onPressed: () async {
                await selectMediaEvidence(EvidenceType.photo);
                setState(() {});
              },
              text: Text('Photos'),
            ),
            myFirstButton(
              onPressed: () async {
                await selectMediaEvidence(EvidenceType.video);
                setState(() {});
              },
              text: Text('Videos').tr(),
            ),
            myFirstButton(
              onPressed: () async {
                await selectMediaEvidence(EvidenceType.audio);
                setState(() {});
              },
              text: Text('Audio'),
            ),
            myFirstButton(
              onPressed: () async {
                await selectMediaEvidence(EvidenceType.document);
                setState(() {});
              },
              text: Text('Documents'),
            ),
          ],
        ),
      ],
    );
  }
}