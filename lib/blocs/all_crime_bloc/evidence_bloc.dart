import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/models/all_crime_models/evidence.dart';
import 'package:crimebook/config/firebase_config.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/all_crime_models/crime.dart';
import 'ciminal_bloc.dart'; // Import FirebaseConfig

class EvidenceBloc extends ChangeNotifier {
  // State variables
  List<Evidence> evidence = [];

  // Pagination variables
  QueryDocumentSnapshot? _lastEvidenceVisible;

  // Loading state
  bool _isLoadingEvidence = true;

  // Getter for loading state
  bool get isLoadingEvidence => _isLoadingEvidence;

  // --- Evidence Operations ---

  // Create a new evidence record
  Future<String?> createEvidence(Evidence newEvidence) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.evidenceCollection).doc();
      newEvidence.id = docRef.id;
      await docRef.set(newEvidence.toJSON());
      evidence.add(newEvidence);

      notifyListeners();
      return newEvidence.id;
    } catch (e) {
      print('Error creating evidence: $e');
    }
  }

  // Retrieve an evidence record by ID
  Future<void> getEvidence(String evidenceId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.evidenceCollection).doc(evidenceId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        evidence.add(Evidence.fromJSON(docSnapshot.data()!));
        notifyListeners();
      }
    } catch (e) {
      print('Error getting evidence: $e');
    }
  }

  // Update an existing evidence record
  Future<void> updateEvidence(Evidence updatedEvidence) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.evidenceCollection).doc(updatedEvidence.id);
      await docRef.update(updatedEvidence.toJSON());
      // Update the evidence in the list if it exists
      final index = evidence.indexWhere((evi) => evi.id == updatedEvidence.id);
      if (index != -1) {
        evidence[index] = updatedEvidence;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating evidence: $e');
    }
  }

  // Delete an evidence record
  Future<void> deleteEvidence(String evidenceId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.evidenceCollection).doc(evidenceId);
      await docRef.delete();
      // Remove the evidence from the list
      evidence.removeWhere((evi) => evi.id == evidenceId);
      notifyListeners();
    } catch (e) {
      print('Error deleting evidence: $e');
    }
  }

  // Fetch all evidence records from Firestore
  Future<void> fetchAllEvidence({bool refresh = false}) async {
    print("in evidence bloc");
    try {
      // Clear existing data if refreshing
      if (refresh) {
        evidence.clear();
        _lastEvidenceVisible = null;
      }

      _isLoadingEvidence = true; // Set loading state to true before fetching

      QuerySnapshot rawData;
      if (_lastEvidenceVisible == null) {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.evidenceCollection)
            .orderBy('timestamp', descending: true) // Order by timestamp for example
            .limit(4)
            .get();
      } else {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.evidenceCollection)
            .orderBy('timestamp', descending: true)
            .startAfter([_lastEvidenceVisible!['timestamp']])
            .limit(4)
            .get();
      }

      if (rawData.docs.length > 0) {
        _lastEvidenceVisible = rawData.docs[rawData.docs.length - 1];
        evidence.addAll(rawData.docs.map((doc) => Evidence.fromJSON(doc.data() as Map<String,dynamic>)).toList());
        _isLoadingEvidence = false; // Set loading state to false after fetching
        notifyListeners();
      } else {
        _isLoadingEvidence = false; // Set loading state to false even if no more data
        print('No more evidence available');
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching evidence: $e');
    }
  }

  // --- Additional Functions ---

  // Add a crime ID to an evidence's associated crimes
  Future<void> addAssociatedCrime(String evidenceId, String crimeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.evidenceCollection).doc(evidenceId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final evidenceItem = Evidence.fromJSON(docSnapshot.data()!);
        evidenceItem.crimeId = crimeId;
        await docRef.update(evidenceItem.toJSON());
        notifyListeners();
      }
    } catch (e) {
      print('Error adding associated crime: $e');
    }
  }

  // Remove a crime ID from an evidence's associated crimes
  Future<void> removeAssociatedCrime(String evidenceId, String crimeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.evidenceCollection).doc(evidenceId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final evidenceItem = Evidence.fromJSON(docSnapshot.data()!);
        evidenceItem.crimeId = null; // Set to null to remove association
        await docRef.update(evidenceItem.toJSON());
        notifyListeners();
      }
    } catch (e) {
      print('Error removing associated crime: $e');
    }
  }

  // Add a witness ID to an evidence's associated witnesses
  Future<void> addAssociatedWitness(String evidenceId, String witnessId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.evidenceCollection).doc(evidenceId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final evidenceItem = Evidence.fromJSON(docSnapshot.data()!);
        evidenceItem.witnessId = witnessId;
        await docRef.update(evidenceItem.toJSON());
        notifyListeners();
      }
    } catch (e) {
      print('Error adding associated witness: $e');
    }
  }

  // Remove a witness ID from an evidence's associated witnesses
  Future<void> removeAssociatedWitness(String evidenceId, String witnessId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.evidenceCollection).doc(evidenceId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final evidenceItem = Evidence.fromJSON(docSnapshot.data()!);
        evidenceItem.witnessId = null; // Set to null to remove association
        await docRef.update(evidenceItem.toJSON());
        notifyListeners();
      }
    } catch (e) {
      print('Error removing associated witness: $e');
    }
  }

  // Add a criminal ID to an evidence's associated criminals
  // (You need to have a `criminalId` field in your Evidence model for this)
  Future<void> addAssociatedCriminal(String evidenceId, String criminalId, {required CriminalBloc criminalBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.evidenceCollection).doc(evidenceId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final evidenceItem = Evidence.fromJSON(docSnapshot.data()!);
        // evidenceItem.criminalId = criminalId;
        await docRef.update(evidenceItem.toJSON());
        // Update associated criminals
        await criminalBloc.addAssociatedEvidence(criminalId, evidenceId);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding associated criminal: $e');
    }
  }

  // Remove a criminal ID from an evidence's associated criminals
  Future<void> removeAssociatedCriminal(String evidenceId, String criminalId, {required CriminalBloc criminalBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.evidenceCollection).doc(evidenceId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final evidenceItem = Evidence.fromJSON(docSnapshot.data()!);
        // evidenceItem.criminalId = null;
        await docRef.update(evidenceItem.toJSON());
        // Update associated criminals
        await criminalBloc.removeAssociatedEvidence(criminalId, evidenceId);
        notifyListeners();
      }
    } catch (e) {
      print('Error removing associated criminal: $e');
    }
  }

  // --- Helper Functions ---
  Future<List<String>> fetchEvidenceImageUrls(Crime crime) async {
    List<String> imageUrls = [];
 print("Lets just show the evidence urls");
 if(crime.evidence != null){
   crime.evidence!.forEach((e){
     print(e.toString());
   });
 };

    if (crime.evidence != null) {
      for (String evidenceId in crime.evidence!) {
        try {
          final DocumentSnapshot evidenceDoc = await FirebaseFirestore.instance
              .collection(FirebaseConfig.evidenceCollection)
              .doc(evidenceId)
              .get();
          print("MyEvidence bloc is: ${evidenceDoc.data()}");

          if (evidenceDoc.exists) {
            final evidenceData = Evidence.fromJSON(evidenceDoc.data() as Map<String, dynamic>);
            if (evidenceData.urls != null) {
              imageUrls.addAll(evidenceData.urls!);
            }
          }
        } catch (e) {
          print('Error fetching evidence: $e');
        }
      }
    }
    print("Before Returning ");
    imageUrls.forEach((e){
      print(e.toString());
    });
    return imageUrls;
  }

  // Function to find an evidence item in the 'evidence' list by ID
  Evidence? findEvidenceById(String evidenceId) {
    return evidence.firstWhere((evi) => evi.id == evidenceId, orElse: () => Evidence());
  }

  // Function to find an evidence item in the 'evidence' list by URL (assuming you have a 'url' field)
  Evidence? findEvidenceByURL(String url) {
    return evidence.firstWhere((evi) => evi.urls!.contains(url), orElse: () => Evidence());
  }

  List<Evidence> allEvidenceToCrime = [];
}