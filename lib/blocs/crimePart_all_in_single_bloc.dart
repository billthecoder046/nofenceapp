import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nofence/models/crime.dart';
import 'package:nofence/models/evidence.dart';
import 'package:nofence/models/witness.dart';
import 'package:nofence/models/comment.dart';

import '../models/judgeRemark.dart';

class AppBloc extends ChangeNotifier {
  // State variables to hold data
  Crime? currentCrime;
  List<Crime> crimes = [];
  List<Judge> judges = [];
  List<Witness> witnesses = [];
  List<Evidence> evidence = [];
  List<JudgeDecision> judgeDecisions = [];

  // --- Crime Operations ---

  Future<void> createCrime(Crime newCrime) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('crimes').doc();
      newCrime.id = docRef.id;
      await docRef.set(newCrime.toJSON());
      crimes.add(newCrime);
      notifyListeners();
    } catch (e) {
      print('Error creating crime: $e');
    }
  }

  Future<void> getCrime(String crimeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('crimes').doc(crimeId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        currentCrime = Crime.fromJSON(docSnapshot.data()!);
        notifyListeners();
      }
    } catch (e) {
      print('Error getting crime: $e');
    }
  }

  Future<void> updateCrime(Crime updatedCrime) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('crimes').doc(updatedCrime.id);
      await docRef.update(updatedCrime.toJSON());
      // Update the crime in the list if it exists
      final index = crimes.indexWhere((crime) => crime.id == updatedCrime.id);
      if (index != -1) {
        crimes[index] = updatedCrime;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating crime: $e');
    }
  }

  Future<void> deleteCrime(String crimeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('crimes').doc(crimeId);
      await docRef.delete();
      // Remove the crime from the list
      crimes.removeWhere((crime) => crime.id == crimeId);
      notifyListeners();
    } catch (e) {
      print('Error deleting crime: $e');
    }
  }

  Future<void> fetchAllCrimes() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('crimes').get();
      crimes = querySnapshot.docs.map((doc) => Crime.fromJSON(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching crimes: $e');
    }
  }

  // --- Judge Operations ---

  Future<void> createJudge(Judge newJudge) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('judges').doc();
      newJudge.id = docRef.id;
      await docRef.set(newJudge.toJSON());
      judges.add(newJudge);
      notifyListeners();
    } catch (e) {
      print('Error creating judge: $e');
    }
  }

  Future<void> getJudge(String judgeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('judges').doc(judgeId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        judges.add(Judge.fromJSON(docSnapshot.data()!));
        notifyListeners();
      }
    } catch (e) {
      print('Error getting judge: $e');
    }
  }

  Future<void> updateJudge(Judge updatedJudge) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('judges').doc(updatedJudge.id);
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

  Future<void> deleteJudge(String judgeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('judges').doc(judgeId);
      await docRef.delete();
      // Remove the judge from the list
      judges.removeWhere((judge) => judge.id == judgeId);
      notifyListeners();
    } catch (e) {
      print('Error deleting judge: $e');
    }
  }

  Future<void> fetchAllJudges() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('judges').get();
      judges = querySnapshot.docs.map((doc) => Judge.fromJSON(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching judges: $e');
    }
  }

  // --- Witness Operations ---

  Future<void> createWitness(Witness newWitness) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('witnesses').doc();
      newWitness.id = docRef.id;
      await docRef.set(newWitness.toJSON());
      witnesses.add(newWitness);
      notifyListeners();
    } catch (e) {
      print('Error creating witness: $e');
    }
  }

  Future<void> getWitness(String witnessId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('witnesses').doc(witnessId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        witnesses.add(Witness.fromJSON(docSnapshot.data()!));
        notifyListeners();
      }
    } catch (e) {
      print('Error getting witness: $e');
    }
  }

  Future<void> updateWitness(Witness updatedWitness) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('witnesses').doc(updatedWitness.id);
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

  Future<void> deleteWitness(String witnessId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('witnesses').doc(witnessId);
      await docRef.delete();
      // Remove the witness from the list
      witnesses.removeWhere((witness) => witness.id == witnessId);
      notifyListeners();
    } catch (e) {
      print('Error deleting witness: $e');
    }
  }

  Future<void> fetchAllWitnesses() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('witnesses').get();
      witnesses = querySnapshot.docs.map((doc) => Witness.fromJSON(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching witnesses: $e');
    }
  }

  // --- Evidence Operations ---

  Future<void> createEvidence(Evidence newEvidence) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('evidence').doc();
      newEvidence.id = docRef.id;
      await docRef.set(newEvidence.toJSON());
      evidence.add(newEvidence);
      notifyListeners();
    } catch (e) {
      print('Error creating evidence: $e');
    }
  }

  Future<void> getEvidence(String evidenceId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('evidence').doc(evidenceId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        evidence.add(Evidence.fromJSON(docSnapshot.data()!));
        notifyListeners();
      }
    } catch (e) {
      print('Error getting evidence: $e');
    }
  }

  Future<void> updateEvidence(Evidence updatedEvidence) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('evidence').doc(updatedEvidence.id);
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

  Future<void> deleteEvidence(String evidenceId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('evidence').doc(evidenceId);
      await docRef.delete();
      // Remove the evidence from the list
      evidence.removeWhere((evi) => evi.id == evidenceId);
      notifyListeners();
    } catch (e) {
      print('Error deleting evidence: $e');
    }
  }

  Future<void> fetchAllEvidence() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('evidence').get();
      evidence = querySnapshot.docs.map((doc) => Evidence.fromJSON(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching evidence: $e');
    }
  }

  // --- Judge Decision Operations ---

  Future<void> createJudgeDecision(JudgeDecision newDecision) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('judgeDecisions').doc();
      newDecision.id = docRef.id;
      await docRef.set(newDecision.toJSON());
      judgeDecisions.add(newDecision);
      notifyListeners();
    } catch (e) {
      print('Error creating judge decision: $e');
    }
  }

  Future<void> getJudgeDecision(String decisionId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('judgeDecisions').doc(decisionId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        judgeDecisions.add(JudgeDecision.fromJSON(docSnapshot.data()!));
        notifyListeners();
      }
    } catch (e) {
      print('Error getting judge decision: $e');
    }
  }

  Future<void> updateJudgeDecision(JudgeDecision updatedDecision) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('judgeDecisions').doc(updatedDecision.id);
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

  Future<void> deleteJudgeDecision(String decisionId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('judgeDecisions').doc(decisionId);
      await docRef.delete();
      // Remove the judge decision from the list
      judgeDecisions.removeWhere((decision) => decision.id == decisionId);
      notifyListeners();
    } catch (e) {
      print('Error deleting judge decision: $e');
    }
  }

  Future<void> fetchAllJudgeDecisions() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('judgeDecisions').get();
      judgeDecisions = querySnapshot.docs.map((doc) => JudgeDecision.fromJSON(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching judge decisions: $e');
    }
  }

  // --- Comment Operations ---

  Future<void> addComment(Comment newComment, String evidenceId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('evidence').doc(evidenceId).collection('comments').doc();
      newComment.id = docRef.id;
      await docRef.set(newComment.toJSON());
      // (Optionally update the evidence object with the new comment)
      notifyListeners();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  Future<void> fetchComments(String evidenceId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('evidence').doc(evidenceId).collection('comments').get();
      // (Optionally update the evidence object with the retrieved comments)
      notifyListeners();
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  // --- Feedback Operations ---

  Future<void> updateCrimeFeedback(String crimeId, String userId, String action, bool isLike) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('crimes').doc(crimeId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final crime = Crime.fromJSON(docSnapshot.data()!);
        if (crime.feedback != null) {
          if (action == 'judgeConclusion') {
            if (isLike) {
              crime.feedback!.judgeLikedConclusion!.add(userId);
              crime.feedback!.judgeLikedConclusionCount = crime.feedback!.judgeLikedConclusion!.length;
            } else {
              crime.feedback!.judgeDislikedConclusion!.add(userId);
              crime.feedback!.judgeDislikedConclusionCount = crime.feedback!.judgeDislikedConclusion!.length;
            }
          } else if (action == 'aiConclusion') {
            if (isLike) {
              crime.feedback!.aiLikedConclusion!.add(userId);
              crime.feedback!.aiLikedConclusionCount = crime.feedback!.aiLikedConclusion!.length;
            } else {
              crime.feedback!.aiDislikedConclusion!.add(userId);
              crime.feedback!.aiDislikedConclusionCount = crime.feedback!.aiDislikedConclusion!.length;
            }
          }
          await docRef.update(crime.toJSON());
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error updating crime feedback: $e');
    }
  }

// --- Additional Functions (As needed) ---

// ... (For example, functions to get data based on specific criteria)

// --- Helper Functions (As needed) ---
// ...

}