import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/config/firebase_config.dart';

import '../../models/all_crime_models/crimefeedback.dart'; // Import FirebaseConfig

class CrimeFeedbackBloc extends ChangeNotifier {
  // State variables
  CrimeFeedback? currentCrimeFeedback;

  // Data lists
  List<CrimeFeedback> crimeFeedbacks = [];

  // Pagination variables (optional if you need pagination)
  QueryDocumentSnapshot? _lastCrimeFeedbackVisible;

  // Loading state
  bool _isLoadingCrimeFeedback = true;

  // Getter for loading state
  bool get isLoadingCrimeFeedback => _isLoadingCrimeFeedback;

  // --- Crime Feedback Operations ---

  // Create a new crime feedback record
  Future<void> createCrimeFeedback(CrimeFeedback newCrimeFeedback) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimeFeedbackCollection).doc(newCrimeFeedback.id);
      await docRef.set(newCrimeFeedback.toJSON());
      crimeFeedbacks.add(newCrimeFeedback);
      notifyListeners();
    } catch (e) {
      print('Error creating crime feedback: $e');
    }
  }

  // Retrieve a crime feedback record by ID
  Future<void> getCrimeFeedback(String crimeFeedbackId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimeFeedbackCollection).doc(crimeFeedbackId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        currentCrimeFeedback = CrimeFeedback.fromJSON(docSnapshot.data()!);
        notifyListeners();
      }
    } catch (e) {
      print('Error getting crime feedback: $e');
    }
  }

  // Update an existing crime feedback record
  Future<void> updateCrimeFeedback(CrimeFeedback updatedCrimeFeedback) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimeFeedbackCollection).doc(updatedCrimeFeedback.crimeId);
      await docRef.update(updatedCrimeFeedback.toJSON());
      // Update the crime feedback in the list if it exists
      final index = crimeFeedbacks.indexWhere((crimeFeedback) => crimeFeedback.crimeId == updatedCrimeFeedback.crimeId);
      if (index != -1) {
        crimeFeedbacks[index] = updatedCrimeFeedback;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating crime feedback: $e');
    }
  }

  // Delete a crime feedback record
  Future<void> deleteCrimeFeedback(String crimeFeedbackId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimeFeedbackCollection).doc(crimeFeedbackId);
      await docRef.delete();
      // Remove the crime feedback from the list
      crimeFeedbacks.removeWhere((crimeFeedback) => crimeFeedback.crimeId == crimeFeedbackId);
      notifyListeners();
    } catch (e) {
      print('Error deleting crime feedback: $e');
    }
  }

  // Fetch all crime feedback records from Firestore
  Future<void> fetchAllCrimeFeedback({bool refresh = false}) async {
    try {
      // Clear existing data if refreshing
      if (refresh) {
        crimeFeedbacks.clear();
        _lastCrimeFeedbackVisible = null;
      }

      _isLoadingCrimeFeedback = true; // Set loading state to true before fetching

      QuerySnapshot rawData;
      if (_lastCrimeFeedbackVisible == null) {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.crimeFeedbackCollection)
            .orderBy('crimeId', descending: false) // Order by crimeId for example
            .limit(4)
            .get();
      } else {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.crimeFeedbackCollection)
            .orderBy('crimeId', descending: false)
            .startAfter([_lastCrimeFeedbackVisible!['crimeId']])
            .limit(4)
            .get();
      }

      if (rawData.docs.length > 0) {
        _lastCrimeFeedbackVisible = rawData.docs[rawData.docs.length - 1];
        crimeFeedbacks.addAll(rawData.docs.map((doc) => CrimeFeedback.fromJSON(doc.data() as Map<String, dynamic>)).toList());
        _isLoadingCrimeFeedback = false; // Set loading state to false after fetching
        notifyListeners();
      } else {
        _isLoadingCrimeFeedback = false; // Set loading state to false even if no more data
        print('No more crime feedback available');
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching crime feedback: $e');
    }
  }

  // --- Helper Functions ---

  // Function to find a crime feedback in the 'crimeFeedbacks' list by ID
  CrimeFeedback? findCrimeFeedbackById(String crimeFeedbackId) {
    return crimeFeedbacks.firstWhere((crimeFeedback) => crimeFeedback.crimeId == crimeFeedbackId, orElse: () => CrimeFeedback());
  }
}