import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../config/firebase_config.dart';
import '../../models/all_crime_models/criminals.dart';

class CriminalBloc extends ChangeNotifier {
  List<Criminal> criminals = [];

  // Pagination variables
  QueryDocumentSnapshot? _lastCriminalVisible;

  // Loading state
  bool _isLoadingCriminals = true;

  // Getter for loading state
  bool get isLoadingCriminals => _isLoadingCriminals;

  // --- Criminal Operations ---

  // Create a new criminal record
  Future<void> createCriminal(Criminal newCriminal) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc();
      newCriminal.id = docRef.id;
      await docRef.set(newCriminal.toJSON());
      criminals.add(newCriminal);
      notifyListeners();
    } catch (e) {
      print('Error creating criminal: $e');
    }
  }

  // Retrieve a criminal record by ID
  Future<void> getCriminal(String criminalId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc(criminalId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        criminals.add(Criminal.fromJSON(docSnapshot.data()!));
        notifyListeners();
      }
    } catch (e) {
      print('Error getting criminal: $e');
    }
  }

  // Update an existing criminal record
  Future<void> updateCriminal(Criminal updatedCriminal) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc(updatedCriminal.id);
      await docRef.update(updatedCriminal.toJSON());
      // Update the criminal in the list if it exists
      final index = criminals.indexWhere((criminal) => criminal.id == updatedCriminal.id);
      if (index != -1) {
        criminals[index] = updatedCriminal;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating criminal: $e');
    }
  }

  // Delete a criminal record
  Future<void> deleteCriminal(String criminalId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc(criminalId);
      await docRef.delete();
      // Remove the criminal from the list
      criminals.removeWhere((criminal) => criminal.id == criminalId);
      notifyListeners();
    } catch (e) {
      print('Error deleting criminal: $e');
    }
  }

  // Fetch all criminal records from Firestore
  Future<void> fetchAllCriminals({bool refresh = false}) async {
    try {
      // Clear existing data if refreshing
      if (refresh) {
        criminals.clear();
        _lastCriminalVisible = null;
      }

      _isLoadingCriminals = true; // Set loading state to true before fetching

      QuerySnapshot rawData;
      if (_lastCriminalVisible == null) {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.criminalsCollection)
            .orderBy('name', descending: false) // Order by name for example
            .limit(4)
            .get();
      } else {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.criminalsCollection)
            .orderBy('name', descending: false)
            .startAfter([_lastCriminalVisible!['name']])
            .limit(4)
            .get();
      }

      if (rawData.docs.length > 0) {
        _lastCriminalVisible = rawData.docs[rawData.docs.length - 1];
        criminals.addAll(rawData.docs.map((doc) => Criminal.fromJSON(doc.data() as Map<String, dynamic>)).toList());
        _isLoadingCriminals = false; // Set loading state to false after fetching
        notifyListeners();
      } else {
        _isLoadingCriminals = false; // Set loading state to false even if no more data
        print('No more criminals available');
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching criminals: $e');
    }
  }

  // Add a crime ID to a criminal's associated crimes
  Future<void> addAssociatedCrime(String criminalId, String crimeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc(criminalId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final criminal = Criminal.fromJSON(docSnapshot.data()!);
        criminal.associatedCrimeIds!.add(crimeId);
        await docRef.update(criminal.toJSON());
        // You can optionally update the criminal in the 'criminals' list if needed.
        notifyListeners();
      }
    } catch (e) {
      print('Error adding associated crime: $e');
    }
  }

  // Remove a crime ID from a criminal's associated crimes
  Future<void> removeAssociatedCrime(String criminalId, String crimeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc(criminalId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final criminal = Criminal.fromJSON(docSnapshot.data()!);
        criminal.associatedCrimeIds!.remove(crimeId);
        await docRef.update(criminal.toJSON());
        // You can optionally update the criminal in the 'criminals' list if needed.
        notifyListeners();
      }
    } catch (e) {
      print('Error removing associated crime: $e');
    }
  }

  // Add a witness ID to a criminal's associated witnesses
  Future<void> addAssociatedWitness(String criminalId, String witnessId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc(criminalId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final criminal = Criminal.fromJSON(docSnapshot.data()!);
        criminal.associatedWitnessIds!.add(witnessId);
        await docRef.update(criminal.toJSON());
        notifyListeners();
      }
    } catch (e) {
      print('Error adding associated witness: $e');
    }
  }

  // Remove a witness ID from a criminal's associated witnesses
  Future<void> removeAssociatedWitness(String criminalId, String witnessId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc(criminalId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final criminal = Criminal.fromJSON(docSnapshot.data()!);
        criminal.associatedWitnessIds!.remove(witnessId);
        await docRef.update(criminal.toJSON());
        notifyListeners();
      }
    } catch (e) {
      print('Error removing associated witness: $e');
    }
  }

  // Add an evidence ID to a criminal's associated evidence
  Future<void> addAssociatedEvidence(String criminalId, String evidenceId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc(criminalId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final criminal = Criminal.fromJSON(docSnapshot.data()!);
        criminal.associatedEvidenceIds!.add(evidenceId);
        await docRef.update(criminal.toJSON());
        notifyListeners();
      }
    } catch (e) {
      print('Error adding associated evidence: $e');
    }
  }

  // Remove an evidence ID from a criminal's associated evidence
  Future<void> removeAssociatedEvidence(String criminalId, String evidenceId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc(criminalId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final criminal = Criminal.fromJSON(docSnapshot.data()!);
        criminal.associatedEvidenceIds!.remove(evidenceId);
        await docRef.update(criminal.toJSON());
        notifyListeners();
      }
    } catch (e) {
      print('Error removing associated evidence: $e');
    }
  }

  // Update the status of a criminal
  Future<void> updateCriminalStatus(String criminalId, String newStatus) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.criminalsCollection).doc(criminalId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final criminal = Criminal.fromJSON(docSnapshot.data()!);
        criminal.status = newStatus;
        await docRef.update(criminal.toJSON());
        notifyListeners();
      }
    } catch (e) {
      print('Error updating criminal status: $e');
    }
  }

  // --- Helper Functions ---

  // Function to find a criminal in the 'criminals' list by ID
  Criminal? findCriminalById(String criminalId) {
    return criminals.firstWhere((criminal) => criminal.id == criminalId, orElse: () => Criminal());
  }

  // Function to find a crime in the 'criminals' list by name
  Criminal? findCriminalByName(String criminalName) {
    return criminals.firstWhere((criminal) => criminal.name == criminalName, orElse: () => Criminal());
  }
}