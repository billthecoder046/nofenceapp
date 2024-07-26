
class Judge {
  String? id;
  String? name;
  String? court; // Optional: Court they belong to
  bool? isAssigned; // True if this judge is assigned to a case
  int? loves; // Counter for conclusions liked by users
  int? disloves; // Counter for conclusions disliked by users
   // Map of remark IDs to dislike counts
  List<String>? assignedCrimeIds; // List of crime IDs assigned to this judge
  List<String>? decisionIds; // List of decision IDs made by this judge

  Judge({
    this.id,
    this.name,
    this.court,
    this.isAssigned = false, // Default is not assigned
    this.loves = 0, // Initialize counters to 0
    this.disloves = 0,
    this.assignedCrimeIds = const [],
    this.decisionIds = const [],
  });

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'court': court,
      'isAssigned': isAssigned,
      'loves': loves,
      'disloves': disloves,
      'assignedCrimeIds': assignedCrimeIds,
      'decisionIds': decisionIds,
    };
  }

  factory Judge.fromJSON(Map<String, dynamic> json) {
    return Judge(
      id: json['id'],
      name: json['name'],
      court: json['court'],
      isAssigned: json['isAssigned'],
      loves: json['disloves'],
      disloves: json['loves'],
      assignedCrimeIds: (json['assignedCrimeIds'] as List?)?.cast<String>(),
      decisionIds: (json['decisionIds'] as List?)?.cast<String>(),
    );
  }
}

// Judge Remark class
class JudgeDecision {
  String? id; // Unique ID for each decision
  String? crimeId; // ID of the crime this decision is related to
  String? judgeId; // ID of the judge who made the decision
  String? decision; // The judge's decision
  DateTime? timestamp; // Timestamp when the decision was made
  List<String>? likedBy; // List of user IDs who liked the decision
  List<String>? dislikedBy; // List of user IDs who disliked the decision
  int? loves; // Counter for likes
  int? disloves; // Counter for dislikes

  JudgeDecision({
    this.id,
    this.crimeId,
    this.judgeId,
    this.decision,
    this.timestamp,
    this.likedBy = const [],
    this.dislikedBy = const [],
    this.loves = 0, // Initialize counters to 0
    this.disloves = 0,
  });

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'crimeId': crimeId,
      'judgeId': judgeId,
      'decision': decision,
      'timestamp': timestamp?.millisecondsSinceEpoch,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'loves': loves,
      'disloves': disloves,
    };
  }

  factory JudgeDecision.fromJSON(Map<String, dynamic> json) {
    return JudgeDecision(
      id: json['id'],
      crimeId: json['crimeId'],
      judgeId: json['judgeId'],
      decision: json['decision'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      likedBy: (json['likedBy'] as List?)?.cast<String>(),
      dislikedBy: (json['dislikedBy'] as List?)?.cast<String>(),
      loves: json['loves'],
      disloves: json['disloves'],
    );
  }
}