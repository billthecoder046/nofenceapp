import 'package:nofence/models/comment.dart';

enum EvidenceType {
  photo, // Photograph
  video, // Video recording
  audio, // Audio recording
  document, // Document (PDF, Word, etc.)
  other, unknown, // Other type of evidence
}

class Evidence {
  String? id; // Unique ID for the evidence
  String? crimeId; // ID of the crime this evidence is associated with
  EvidenceType? evidenceType; // Type of evidence
  List<String>? urls; // List of URLs for the evidence files (stored in Firebase Storage)
  String? description; // Optional description of the evidence
  String? witnessId; // ID of the witness who provided this evidence
  String? testimony; // Witness's statement related to this evidence
  List<Comment>? comments;// List of comments on this evidence

  Evidence({
    this.id,
    this.crimeId,
    this.evidenceType,
    this.urls = const [], // Initialize as an empty list
    this.description,
    this.witnessId,
    this.testimony,
    this.comments = const [], // Initialize as an empty list
  });

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'crimeId': crimeId,
      'evidenceType': evidenceType?.name, // Store enum as string
      'urls': urls,
      'description': description,
      'witnessId': witnessId,
      'testimony': testimony,
      'comments': comments?.map((c) => c.toJSON()).toList(),
    };
  }

  factory Evidence.fromJSON(Map<String, dynamic> json) {
    print(json);
    return Evidence(
      id: json['id']??'',
      crimeId: json['crimeId']??'',
      evidenceType: EvidenceType.values.byName(json['evidenceType']??'unknown'), // Retrieve enum from string
      urls: (json['urls'] as List?)?.cast<String>()??[],
      description: json['description']??'',
      witnessId: json['witnessId']??'',
      testimony: json['testimony']??'',
      comments: (json['comments'] as List?)
          ?.map((c) => Comment.fromJSON(c))
          .toList()??[],
    );
  }
}