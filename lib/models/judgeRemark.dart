
class Judge {
  String? id;
  String? name;
  String? court; // Optional: Court they belong to
  bool? isAssigned; // True if this judge is assigned to a case
  int? likedConclusionCount; // Counter for conclusions liked by users
  int? dislikedConclusionCount; // Counter for conclusions disliked by users
  Map<String, int>? remarkLikes; // Map of remark IDs to like counts
  Map<String, int>? remarkDislikes; // Map of remark IDs to dislike counts
  List<String>? assignedCrimeIds; // List of crime IDs assigned to this judge
  List<String>? decisionIds; // List of decision IDs made by this judge

  Judge({
    this.id,
    this.name,
    this.court,
    this.isAssigned = false, // Default is not assigned
    this.likedConclusionCount = 0, // Initialize counters to 0
    this.dislikedConclusionCount = 0,
    this.remarkLikes = const {},
    this.remarkDislikes = const {},
    this.assignedCrimeIds = const [],
    this.decisionIds = const [],
  });

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'court': court,
      'isAssigned': isAssigned,
      'likedConclusionCount': likedConclusionCount,
      'dislikedConclusionCount': dislikedConclusionCount,
      'remarkLikes': remarkLikes,
      'remarkDislikes': remarkDislikes,
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
      likedConclusionCount: json['likedConclusionCount'],
      dislikedConclusionCount: json['dislikedConclusionCount'],
      remarkLikes: (json['remarkLikes'] as Map?)?.cast<String, int>(),
      remarkDislikes: (json['remarkDislikes'] as Map?)?.cast<String, int>(),
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
  int? likeCount; // Counter for likes
  int? dislikeCount; // Counter for dislikes

  JudgeDecision({
    this.id,
    this.crimeId,
    this.judgeId,
    this.decision,
    this.timestamp,
    this.likedBy = const [],
    this.dislikedBy = const [],
    this.likeCount = 0, // Initialize counters to 0
    this.dislikeCount = 0,
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
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
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
      likeCount: json['likeCount'],
      dislikeCount: json['dislikeCount'],
    );
  }
}