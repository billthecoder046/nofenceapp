import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/models/all_crime_models/judgeRemark.dart';
import 'package:crimebook/config/firebase_config.dart'; // Import FirebaseConfig
import '../../models/all_crime_models/crime.dart';
import 'crime_bloc.dart';

class JudgeBloc extends ChangeNotifier {
  // State variables
  List<Judge> judges = [];
  List<JudgeDecision> judgeDecisions = [];

  // Pagination variables
  QueryDocumentSnapshot? _lastJudgeVisible;
  QueryDocumentSnapshot? _lastJudgeDecisionVisible;

  // Loading states
  bool _isLoadingJudges = true;
  bool _isLoadingJudgeDecisions = true;

  // Getters for loading states
  bool get isLoadingJudges => _isLoadingJudges;
  bool get isLoadingJudgeDecisions => _isLoadingJudgeDecisions;

  // --- Judge Operations ---

  // Create a new judge record
  Future<void> createJudge(Judge newJudge) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.judgesCollection).doc();
      newJudge.id = docRef.id;
      await docRef.set(newJudge.toJSON());
      judges.add(newJudge);
      notifyListeners();
    } catch (e) {
      print('Error creating judge: $e');
    }
  }

  // Retrieve a judge record by ID
  Future<void> getJudge(String judgeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.judgesCollection).doc(judgeId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        judges.add(Judge.fromJSON(docSnapshot.data()!));
        notifyListeners();
      }
    } catch (e) {
      print('Error getting judge: $e');
    }
  }

  // Update an existing judge record
  Future<void> updateJudge(Judge updatedJudge) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.judgesCollection).doc(updatedJudge.id);
      await docRef.update(updatedJudge.toJSON());
      // Update the judge in the list if it exists
      final index = judges.indexWhere((judge) => judge.id == updatedJudge.id);
      if (index != -1) {
        judges[index] = updatedJudge;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating judge: $e');
    }
  }

  // Delete a judge record
  Future<void> deleteJudge(String judgeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.judgesCollection).doc(judgeId);
      await docRef.delete();
      // Remove the judge from the list
      judges.removeWhere((judge) => judge.id == judgeId);
      notifyListeners();
    } catch (e) {
      print('Error deleting judge: $e');
    }
  }

  // Fetch all judge records from Firestore
  Future<void> fetchAllJudges({bool refresh = false}) async {
    try {
      // Clear existing data if refreshing
      if (refresh) {
        judges.clear();
        _lastJudgeVisible = null;
      }

      _isLoadingJudges = true; // Set loading state to true before fetching

      QuerySnapshot rawData;
      if (_lastJudgeVisible == null) {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.judgesCollection)
            .orderBy('name', descending: false) // Order by name for example
            .limit(4)
            .get();
      } else {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.judgesCollection)
            .orderBy('name', descending: false)
            .startAfter([_lastJudgeVisible!['name']])
            .limit(4)
            .get();
      }

      if (rawData.docs.length > 0) {
        _lastJudgeVisible = rawData.docs[rawData.docs.length - 1];
        judges.addAll(rawData.docs.map((doc) => Judge.fromJSON(doc.data() as Map<String, dynamic>)).toList());
        _isLoadingJudges = false; // Set loading state to false after fetching
        notifyListeners();
      } else {
        _isLoadingJudges = false; // Set loading state to false even if no more data
        print('No more judges available');
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching judges: $e');
    }
  }

  // --- Judge Decision Operations ---

  // Create a new judge decision
  Future<void> createJudgeDecision(JudgeDecision newDecision) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.judgeDecisionsCollection).doc();
      newDecision.id = docRef.id;
      await docRef.set(newDecision.toJSON());
      judgeDecisions.add(newDecision);
      notifyListeners();
    } catch (e) {
      print('Error creating judge decision: $e');
    }
  }

  // Retrieve a judge decision by ID
  Future<void> getJudgeDecision(String decisionId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.judgeDecisionsCollection).doc(decisionId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        judgeDecisions.add(JudgeDecision.fromJSON(docSnapshot.data()!));
        notifyListeners();
      }
    } catch (e) {
      print('Error getting judge decision: $e');
    }
  }

  // Update an existing judge decision
  Future<void> updateJudgeDecision(JudgeDecision updatedDecision) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.judgeDecisionsCollection).doc(updatedDecision.id);
      await docRef.update(updatedDecision.toJSON());
      // Update the judge decision in the list if it exists
      final index = judgeDecisions.indexWhere((decision) => decision.id == updatedDecision.id);
      if (index != -1) {
        judgeDecisions[index] = updatedDecision;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating judge decision: $e');
    }
  }

  // Delete a judge decision
  Future<void> deleteJudgeDecision(String decisionId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.judgeDecisionsCollection).doc(decisionId);
      await docRef.delete();
      // Remove the judge decision from the list
      judgeDecisions.removeWhere((decision) => decision.id == decisionId);
      notifyListeners();
    } catch (e) {
      print('Error deleting judge decision: $e');
    }
  }

  // Fetch all judge decisions from Firestore
  Future<void> fetchAllJudgeDecisions({bool refresh = false}) async {
    try {
      // Clear existing data if refreshing
      if (refresh) {
        judgeDecisions.clear();
        _lastJudgeDecisionVisible = null;
      }

      _isLoadingJudgeDecisions = true; // Set loading state to true before fetching

      QuerySnapshot rawData;
      if (_lastJudgeDecisionVisible == null) {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.judgeDecisionsCollection)
            .orderBy('timestamp', descending: true) // Order by timestamp for example
            .limit(4)
            .get();
      } else {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.judgeDecisionsCollection)
            .orderBy('timestamp', descending: true)
            .startAfter([_lastJudgeDecisionVisible!['timestamp']])
            .limit(4)
            .get();
      }

      if (rawData.docs.length > 0) {
        _lastJudgeDecisionVisible = rawData.docs[rawData.docs.length - 1];
        judgeDecisions.addAll(rawData.docs.map((doc) => JudgeDecision.fromJSON(doc.data()  as Map<String, dynamic>)).toList());
        _isLoadingJudgeDecisions = false; // Set loading state to false after fetching
        notifyListeners();
      } else {
        _isLoadingJudgeDecisions = false; // Set loading state to false even if no more data
        print('No more judge decisions available');
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching judge decisions: $e');
    }
  }

  // --- Additional Functions ---

  // Assign a judge to a crime
  Future<void> assignJudgeToCrime(String crimeId, String judgeId, {required CrimeBloc crimeBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimesCollection).doc(crimeId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final crime = Crime.fromJSON(docSnapshot.data()!);
        crime.assignedJudgeId = judgeId;
        await docRef.update(crime.toJSON());
        // Update the judge's assignedCrimeIds
        await updateJudgeAssignedCrimes(judgeId, crimeId);
        // Notify CrimeBloc
        crimeBloc.updateCrime(crime);
        notifyListeners();
      }
    } catch (e) {
      print('Error assigning judge to crime: $e');
    }
  }

  // Unassign a judge from a crime
  Future<void> unassignJudgeFromCrime(String crimeId, String judgeId, {required CrimeBloc crimeBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimesCollection).doc(crimeId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final crime = Crime.fromJSON(docSnapshot.data()!);
        crime.assignedJudgeId = null; // Clear the assigned judge
        await docRef.update(crime.toJSON());
        // Update the judge's assignedCrimeIds
        await updateJudgeAssignedCrimes(judgeId, crimeId, remove: true);
        // Notify CrimeBloc
        crimeBloc.updateCrime(crime);
        notifyListeners();
      }
    } catch (e) {
      print('Error unassigning judge from crime: $e');
    }
  }

  // Update a judge's assignedCrimeIds list
  Future<void> updateJudgeAssignedCrimes(String judgeId, String crimeId, {bool remove = false}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.judgesCollection).doc(judgeId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final judge = Judge.fromJSON(docSnapshot.data()!);
        if (remove) {
          judge.assignedCrimeIds!.remove(crimeId);
        } else {
          judge.assignedCrimeIds!.add(crimeId);
        }
        await docRef.update(judge.toJSON());
        notifyListeners();
      }
    } catch (e) {
      print('Error updating judge assigned crimes: $e');
    }
  }

  // --- Helper Functions ---

  // Find a judge by ID
  Judge? findJudgeById(String judgeId) {
    return judges.firstWhere((judge) => judge.id == judgeId, orElse: () => Judge());
  }

  // Find a judge by name
  Judge? findJudgeByName(String judgeName) {
    return judges.firstWhere((judge) => judge.name == judgeName, orElse: () => Judge());
  }
}