import 'package:crimebook/models/all_crime_models/witness.dart';
import 'package:crimebook/models/all_crime_models/evidence.dart';

import '../../config/config.dart';
import 'crimefeedback.dart';
import 'judgeRemark.dart'; // Import the Criminal model

class Crime {
  String? id; // Optional: To store document ID from Firebase
  CrimeType? crimeCategory; // Category of the crime
  // Removed 'crimeType'
  // No need for 'latitude' and 'longitude' directly
  Map<String, dynamic>? location = {}; // Location data for GeoFirestore (g: geohash, l: [latitude, longitude])
  DateTime? postDate; // Date and time of the crime
  DateTime? crimeDate; // Date and time of the crime
  String? userDescription; // Detailed description of the crime provided by the user
  String? userTitle; // Detailed description of the crime provided by the user
  List<String>? witnesses = []; // List of witnes ses associated with the crime
  List<String>? evidence = []; // List of evidence associated with the crime
  String? status; // E.g., "open", "closed", "resolved"
  String? conclusion; // AI-generated conclusion about the crime
  String? judgeDescription; // Judge's own description of the case
  List<String>? judgeRemarks; // List of judge remarks
  String? assignedJudgeId; // ID of the judge assigned to the case
  String? feedback; // Embedded CrimeFeedback object
  List<String>? criminalIds = []; // List of IDs of criminals associated with the crime

  // Constructor for creating a new crime object
  Crime({
    this.id,
    this.crimeCategory,
    this.location, // Add the location field
    this.postDate,
    this.crimeDate,
    this.userDescription,
    this.userTitle,
    this.witnesses,
    this.evidence,
    this.status,
    this.conclusion,
    this.judgeDescription,
    this.judgeRemarks ,
    this.assignedJudgeId,
    this.feedback,
    this.criminalIds , // Initialize as an empty list
  });

  // Function to convert Crime object to JSON
  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'crimeCategory': crimeCategory?.name, // Store enum value as string
      // Removed 'crimeType'
      // No need to include 'latitude' and 'longitude' individually
      'location': location, // Include the location field for GeoFirestore
      'postDate': postDate?.millisecondsSinceEpoch, // Store postDate as timestamp
      'crimeDate': crimeDate?.millisecondsSinceEpoch, // Store crimeDate as timestamp
      'description': userDescription,
      'userTitle': userTitle,
      'witnesses': witnesses,
      'evidence': evidence,
      'status': status,
      'conclusion': conclusion,
      'judgeDescription': judgeDescription,
      'judgeRemarks': judgeRemarks,
      'assignedJudgeId': assignedJudgeId,
      'feedback': feedback,
      'criminalIds': criminalIds, // Include the list of criminal IDs
    };
  }

  // Function to create a Crime object from JSON
  factory Crime.fromJSON(Map<String, dynamic> json) {
    return Crime(
      id: json['id'],
      crimeCategory: CrimeType.values.byName(json['crimeCategory'] ?? 'unknown'), // Handle null enum values
      // Removed 'crimeType'
      // Retrieve the location field for GeoFirestore
      location: json['location'],
      postDate: json['postDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['postDate']) : null,
      crimeDate: json['crimeDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['crimeDate']) : null,
      userDescription: json['description'],
      userTitle: json['userTitle'],
      witnesses: (json['witnesses'] as List?)?.cast<String>(),
      evidence: (json['evidence'] as List?)?.cast<String>(),
      status: json['status'],
      conclusion: json['conclusion'],
      judgeDescription: json['judgeDescription'],
      judgeRemarks: (json['judgeRemarks'] as List?)?.cast<String>(),
      assignedJudgeId: json['assignedJudgeId'],
      feedback: json['feedback'],
      criminalIds: (json['criminalIds'] as List?)?.cast<String>(), // Retrieve list of criminal IDs
    );
  }
}