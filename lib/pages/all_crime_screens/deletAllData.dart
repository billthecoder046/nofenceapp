import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/firebase_config.dart';

class DeleteAllDataButton extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _showConfirmationDialog(context);
      },
      child: const Text('Clear DB'),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Data?'),
          content: const Text('Are you sure you want to delete ALL data from Firebase? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () async {
                // Delete all data in each collection
                await _deleteAllData();

                Navigator.of(context).pop();

                // Show a success message (or handle the result appropriately)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('All data deleted successfully!')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllData() async {
    // Delete all data in each collection
    await firestore.collection(FirebaseConfig.crimesCollection).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await firestore.collection(FirebaseConfig.judgesCollection).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await firestore.collection(FirebaseConfig.witnessesCollection).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await firestore.collection(FirebaseConfig.evidenceCollection).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await firestore.collection(FirebaseConfig.judgeDecisionsCollection).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await firestore.collection(FirebaseConfig.criminalsCollection).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await firestore.collection(FirebaseConfig.crimeFeedbackCollection).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await firestore.collection(FirebaseConfig.usersCollection).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}