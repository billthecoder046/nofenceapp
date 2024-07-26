import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nofence/models/comment.dart';
import 'package:nofence/config/firebase_config.dart'; // Import FirebaseConfig

class CommentBloc extends ChangeNotifier {
  // State variables
  List<Comment> comments = [];

  // Pagination variables (optional if you need pagination)
  QueryDocumentSnapshot? _lastCommentVisible;

  // Loading state
  bool _isLoadingComments = true;

  // Getter for loading state
  bool get isLoadingComments => _isLoadingComments;

  // --- Comment Operations ---

  // Create a new comment
  Future<void> createComment(Comment newComment, String targetId, String targetType) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(targetType) // 'evidence', 'crime', 'judgeDecision', etc.
          .doc(targetId)
          .collection(FirebaseConfig.commentsSubcollection) // Use FirebaseConfig
          .doc();
      newComment.id = docRef.id;
      await docRef.set(newComment.toJSON());
      comments.add(newComment);
      notifyListeners();
    } catch (e) {
      print('Error creating comment: $e');
    }
  }

  // Retrieve comments for a specific target (evidence, crime, etc.)
  Future<void> fetchComments(String targetId, String targetType) async {
    try {
      // Clear existing comments for this target
      comments.removeWhere((comment) => comment.id!.startsWith('$targetType-$targetId'));

      _isLoadingComments = true; // Set loading state to true before fetching

      final querySnapshot = await FirebaseFirestore.instance
          .collection(targetType)
          .doc(targetId)
          .collection(FirebaseConfig.commentsSubcollection) // Use FirebaseConfig
          .orderBy('timestamp', descending: true) // Order by timestamp
          .get();
      comments.addAll(querySnapshot.docs.map((doc) => Comment.fromJSON(doc.data())).toList());
      _isLoadingComments = false; // Set loading state to false after fetching
      notifyListeners();
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  // Update an existing comment (You might not need this if you don't allow comment editing)
  Future<void> updateComment(Comment updatedComment, String targetId, String targetType) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(targetType)
          .doc(targetId)
          .collection(FirebaseConfig.commentsSubcollection) // Use FirebaseConfig
          .doc(updatedComment.id);
      await docRef.update(updatedComment.toJSON());
      // Update the comment in the list if it exists
      final index = comments.indexWhere((comment) => comment.id == updatedComment.id);
      if (index != -1) {
        comments[index] = updatedComment;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating comment: $e');
    }
  }

  // Delete a comment
  Future<void> deleteComment(String targetId, String commentId, String targetType) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(targetType)
          .doc(targetId)
          .collection(FirebaseConfig.commentsSubcollection) // Use FirebaseConfig
          .doc(commentId);
      await docRef.delete();
      // Remove the comment from the list
      comments.removeWhere((comment) => comment.id == commentId);
      notifyListeners();
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }

  // --- Helper Functions ---

  // Find a comment in the 'comments' list by ID
  Comment? findCommentById(String commentId) {
    return comments.firstWhere((comment) => comment.id == commentId, orElse: () => Comment());
  }
}