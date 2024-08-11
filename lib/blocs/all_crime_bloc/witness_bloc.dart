import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/models/all_crime_models/witness.dart';
import 'package:crimebook/config/firebase_config.dart';

import 'ciminal_bloc.dart';
import 'crime_bloc.dart';
import 'evidence_bloc.dart'; // Import FirebaseConfig

class WitnessBloc extends ChangeNotifier {
  // State variables
  List<Witness> witnesses = [];

  // Pagination variables
  QueryDocumentSnapshot? _lastWitnessVisible;

  // Loading state
  bool _isLoadingWitnesses = true;

  // Getter for loading state
  bool get isLoadingWitnesses => _isLoadingWitnesses;

  // --- Witness Operations ---

  // Create a new witness record
  Future<String?> createWitness(Witness newWitness) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.witnessesCollection).doc(newWitness.id);

      await docRef.set(newWitness.toJSON());
      witnesses.add(newWitness);

      notifyListeners();
      return newWitness.id;
    } catch (e) {
      print('Error creating witness: $e');
    }
  }

  // Retrieve a witness record by ID
  Future<void> getWitness(String witnessId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.witnessesCollection).doc(witnessId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        witnesses.add(Witness.fromJSON(docSnapshot.data()!));
        notifyListeners();
      }
    } catch (e) {
      print('Error getting witness: $e');
    }
  }

  // Update an existing witness record
  Future<void> updateWitness(Witness updatedWitness) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.witnessesCollection).doc(updatedWitness.id);
      await docRef.update(updatedWitness.toJSON());
      // Update the witness in the list if it exists
      final index = witnesses.indexWhere((witness) => witness.id == updatedWitness.id);
      if (index != -1) {
        witnesses[index] = updatedWitness;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating witness: $e');
    }
  }

  // Delete a witness record
  Future<void> deleteWitness(String witnessId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.witnessesCollection).doc(witnessId);
      await docRef.delete();
      // Remove the witness from the list
      witnesses.removeWhere((witness) => witness.id == witnessId);
      notifyListeners();
    } catch (e) {
      print('Error deleting witness: $e');
    }
  }

  // Fetch all witness records from Firestore
  Future<void> fetchAllWitnesses({bool refresh = false}) async {
    try {
      // Clear existing data if refreshing
      if (refresh) {
        witnesses.clear();
        _lastWitnessVisible = null;
      }

      _isLoadingWitnesses = true; // Set loading state to true before fetching

      QuerySnapshot rawData;
      if (_lastWitnessVisible == null) {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.witnessesCollection)
            .orderBy('name', descending: false) // Order by name for example
            .limit(4)
            .get();
      } else {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.witnessesCollection)
            .orderBy('name', descending: false)
            .startAfter([_lastWitnessVisible!['name']])
            .limit(4)
            .get();
      }

      if (rawData.docs.length > 0) {
        _lastWitnessVisible = rawData.docs[rawData.docs.length - 1];
        witnesses.addAll(rawData.docs.map((doc) {
          print("Doc data is: ${doc.data()}");
          return Witness.fromJSON(doc.data() as Map<String,dynamic>);}).toList());
        _isLoadingWitnesses = false; // Set loading state to false after fetching
        notifyListeners();
      } else {
        _isLoadingWitnesses = false; // Set loading state to false even if no more data
        print('No more witnesses available');
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching witnesses: $e');
    }
  }

  // --- Additional Functions ---

  // Add a crime ID to a witness's associated crimes
  Future<void> addAssociatedCrime(String witnessId, String crimeId, {required CrimeBloc crimeBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.witnessesCollection).doc(witnessId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final witness = Witness.fromJSON(docSnapshot.data()!);
        // witness.associatedCrimeIds!.add(crimeId);
        await docRef.update(witness.toJSON());
        // Update associated crimes
        // await crimeBloc.addAssociatedWitness(crimeId, witnessId);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding associated crime: $e');
    }
  }

  // Remove a crime ID from a witness's associated crimes
  Future<void> removeAssociatedCrime(String witnessId, String crimeId, {required CrimeBloc crimeBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.witnessesCollection).doc(witnessId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final witness = Witness.fromJSON(docSnapshot.data()!);
        // witness.associatedCrimeIds!.remove(crimeId);
        await docRef.update(witness.toJSON());
        // Update associated crimes
        // await crimeBloc.removeAssociatedWitness(crimeId, witnessId);
        notifyListeners();
      }
    } catch (e) {
      print('Error removing associated crime: $e');
    }
  }

  // Add a criminal ID to a witness's associated criminals
  Future<void> addAssociatedCriminal(String witnessId, String criminalId, {required CriminalBloc criminalBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.witnessesCollection).doc(witnessId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final witness = Witness.fromJSON(docSnapshot.data()!);
        // witness.associatedCriminalIds!.add(criminalId);
        await docRef.update(witness.toJSON());
        // Update associated criminals
        await criminalBloc.addAssociatedWitness(criminalId, witnessId);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding associated criminal: $e');
    }
  }

  // Remove a criminal ID from a witness's associated criminals
  Future<void> removeAssociatedCriminal(String witnessId, String criminalId, {required CriminalBloc criminalBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.witnessesCollection).doc(witnessId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final witness = Witness.fromJSON(docSnapshot.data()!);
        // witness.associatedCriminalIds!.remove(criminalId);
        await docRef.update(witness.toJSON());
        // Update associated criminals
        await criminalBloc.removeAssociatedWitness(criminalId, witnessId);
        notifyListeners();
      }
    } catch (e) {
      print('Error removing associated criminal: $e');
    }
  }

  // Add an evidence ID to a witness's associated evidence
  Future<void> addAssociatedEvidence(String witnessId, String evidenceId, {required EvidenceBloc evidenceBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.witnessesCollection).doc(witnessId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final witness = Witness.fromJSON(docSnapshot.data()!);
        // witness.associatedEvidenceIds!.add(evidenceId);
        await docRef.update(witness.toJSON());
        // Update associated evidence
        await evidenceBloc.addAssociatedWitness(evidenceId, witnessId);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding associated evidence: $e');
    }
  }

  // Remove an evidence ID from a witness's associated evidence
  Future<void> removeAssociatedEvidence(String witnessId, String evidenceId, {required EvidenceBloc evidenceBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.witnessesCollection).doc(witnessId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final witness = Witness.fromJSON(docSnapshot.data()!);
        // witness.associatedEvidenceIds!.remove(evidenceId);
        await docRef.update(witness.toJSON());
        // Update associated evidence
        await evidenceBloc.removeAssociatedWitness(evidenceId, witnessId);
        notifyListeners();
      }
    } catch (e) {
      print('Error removing associated evidence: $e');
    }
  }

  // --- Helper Functions ---

  // Function to find a witness in the 'witnesses' list by ID
  Witness? findWitnessById(String witnessId) {
    return witnesses.firstWhere((witness) => witness.id == witnessId, orElse: () => Witness());
  }

  // Function to find a witness in the 'witnesses' list by name
  Witness? findWitnessByName(String witnessName) {
    return witnesses.firstWhere((witness) => witness.name == witnessName, orElse: () => Witness());
  }

  Future<void> fetchWitnessesByIds(List<String> witnessIds) async {
    try {
      witnesses.clear(); // Clear existing witnesses
      _isLoadingWitnesses = true; // Set loading state to true
      print("Fetching withness ${witnessIds.toString()}");
      // Fetch each witness by ID
      for (final witnessId in witnessIds) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection(FirebaseConfig.witnessesCollection)
            .doc(witnessId)
            .get();
        if (docSnapshot.exists) {
          print("0");
          print("Doc data : ${docSnapshot.data().toString()}");
          witnesses.add(Witness.fromJSON(docSnapshot.data()!));
          print("1");
        }else{
          print("doc not ezist");
        }
      }

      print("Witness length: ${witnesses.toString()}");

      _isLoadingWitnesses = false; // Set loading state to false
      notifyListeners();
    } catch (e) {
      print('Error fetching witnesses by IDs: $e');
    }
  }
}