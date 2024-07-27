import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../blocs/all_crime_bloc/ciminal_bloc.dart';
import '../../utils/buttons.dart';
import 'criminals.dart';

class CriminalDetails extends StatefulWidget {
  CriminalDetails({super.key});

  @override
  State<CriminalDetails> createState() => _CriminalDetailsState();
}

class _CriminalDetailsState extends State<CriminalDetails> {
  final _formKeyCriminal = GlobalKey<FormBuilderState>();

  // Criminal related state
  final _criminalSearchController = TextEditingController();
  List<Criminal> _filteredCriminals = [];
  bool _isLoadingCriminals = false;
  List<XFile> _selectedCMedia = [];
  List<String> crimeMediaUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isGettingLocation = false;
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
    );

    // Upload Images to Firebase Storage
    for (var mediaCFile in _selectedCMedia) {
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
          _selectedCMedia.addAll(pickedMedia) ;
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
          _selectedCMedia.add(pickedMedia);
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
        title: Text('Select or Add Criminal').tr(),
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
                                  ? Center(child: Text('No Criminals Found'))
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
                            SizedBox(height: 10),
                            selectMedia(context),
                            SizedBox(height: 10),
                            if (_selectedCMedia.isNotEmpty)
                              SizedBox(
                                height: 150,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    for (var mediaFile in _selectedCMedia)
                                      Stack(
                                        alignment: Alignment.bottomLeft,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right: 10),
                                            height: 150,
                                            width: 150,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.file(
                                                File(mediaFile.path),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Container(

                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: IconButton(onPressed: (){
                                              setState(() {
                                                _selectedCMedia.remove(mediaFile);
                                              });
                                            }, icon: Icon(Icons.delete_forever,color: Colors.white,size: 20,)),
                                          )
                                        ],
                                      ),
                                  ],
                                ),
                              ),
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
              text: Text('Clear'),
            ),
            myFirstButton(
              onPressed: () => Navigator.of(context).pop(),
              text: Text('Cancel'),
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
              text: Text('Save'),
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
              Text("${_selectedCMedia.isNotEmpty ? 'Images Selected'.tr() : 'Select Evidence Images (Optional)'.tr()}"),
              _selectedCMedia.isNotEmpty?TextButton(child:Text('Delete All' ,style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),), onPressed: (){
                setState(() {
                  _selectedCMedia.clear();
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
                      Text('Camera')
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