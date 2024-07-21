
import 'package:nofence/models/witness.dart';
import 'package:nofence/models/evidence.dart';

import '../config/config.dart';
import 'crimefeedback.dart';
import 'judgeRemark.dart';



class Crime {
  String? id; // Optional: To store document ID from Firebase
  CrimeType? crimeCategory; // Category of the crime
  String? crimeType; // E.g., "murder", "theft", "assault"
  double? latitude; // Latitude coordinate of the crime
  double? longitude; // Longitude coordinate of the crime
  DateTime? date; // Date and time of the crime
  String? userDescription; // Detailed description of the crime provided by the user
  List<Witness>? witnesses; // List of witnesses associated with the crime
  List<Evidence>? evidence; // List of evidence associated with the crime
  String? status; // E.g., "open", "closed", "resolved"
  String? conclusion; // AI-generated conclusion about the crime
  String? judgeDescription; // Judge's own description of the case
  List<JudgeDecision>? judgeRemarks; // List of judge remarks
  String? assignedJudgeId; // ID of the judge assigned to the case
  CrimeFeedback? feedback; // Embedded CrimeFeedback object

  // Constructor for creating a new crime object
  Crime({
    this.id,
    this.crimeCategory,
    this.crimeType,
    this.latitude,
    this.longitude,
    this.date,
    this.userDescription,
    this.witnesses = const [],
    this.evidence = const [],
    this.status,
    this.conclusion,
    this.judgeDescription,
    this.judgeRemarks = const [],
    this.assignedJudgeId,
    this.feedback,
  });

  // Function to convert Crime object to JSON
  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'crimeCategory': crimeCategory?.name, // Store enum value as string
      'crimeType': crimeType,
      'latitude': latitude,
      'longitude': longitude,
      'date': date?.millisecondsSinceEpoch, // Store date as timestamp
      'description': userDescription,
      'witnesses': witnesses?.map((w) => w.toJSON()).toList(),
      'evidence': evidence?.map((e) => e.toJSON()).toList(),
      'status': status,
      'conclusion': conclusion,
      'judgeDescription': judgeDescription,
      'judgeRemarks': judgeRemarks?.map((r) => r.toJSON()).toList(),
      'assignedJudgeId': assignedJudgeId,
      'feedback': feedback?.toJSON(),
    };
  }

  // Function to create a Crime object from JSON
  factory Crime.fromJSON(Map<String, dynamic> json) {
    return Crime(
      id: json['id'],
      crimeCategory: CrimeType.values.byName(json['crimeCategory']), // Retrieve enum from string
      crimeType: json['crimeType'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      userDescription: json['description'],
      witnesses: (json['witnesses'] as List?)
          ?.map((w) => Witness.fromJSON(w))
          .toList(),
      evidence: (json['evidence'] as List?)
          ?.map((e) => Evidence.fromJSON(e))
          .toList(),
      status: json['status'],
      conclusion: json['conclusion'],
      judgeDescription: json['judgeDescription'],
      judgeRemarks: (json['judgeRemarks'] as List?)
          ?.map((r) => JudgeDecision.fromJSON(r))
          .toList(),
      assignedJudgeId: json['assignedJudgeId'],
      feedback: json['feedback'] != null ? CrimeFeedback.fromJSON(json['feedback']) : null,
    );
  }
}
