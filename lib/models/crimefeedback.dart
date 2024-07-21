

class CrimeFeedback {
  String? crimeId;
  List<String>? judgeLikedConclusion; // Judge IDs who liked conclusion
  int? judgeLikedConclusionCount; // Counter for judges who liked conclusion
  List<String>? judgeDislikedConclusion; // Judge IDs who disliked conclusion
  int? judgeDislikedConclusionCount; // Counter for judges who disliked conclusion
  List<String>? aiLikedConclusion; // AI IDs who liked conclusion
  int? aiLikedConclusionCount; // Counter for AI who liked conclusion
  List<String>? aiDislikedConclusion; // AI IDs who disliked conclusion
  int? aiDislikedConclusionCount; // Counter for AI who disliked conclusion

  // Constructor
  CrimeFeedback({
    this.crimeId,
    this.judgeLikedConclusion = const [],
    this.judgeLikedConclusionCount = 0,
    this.judgeDislikedConclusion = const [],
    this.judgeDislikedConclusionCount = 0,
    this.aiLikedConclusion = const [],
    this.aiLikedConclusionCount = 0,
    this.aiDislikedConclusion = const [],
    this.aiDislikedConclusionCount = 0,
  });

  // Function to convert CrimeFeedback object to JSON
  Map<String, dynamic> toJSON() {
    return {
      'crimeId': crimeId,
      'judgeLikedConclusion': judgeLikedConclusion,
      'judgeLikedConclusionCount': judgeLikedConclusionCount,
      'judgeDislikedConclusion': judgeDislikedConclusion,
      'judgeDislikedConclusionCount': judgeDislikedConclusionCount,
      'aiLikedConclusion': aiLikedConclusion,
      'aiLikedConclusionCount': aiLikedConclusionCount,
      'aiDislikedConclusion': aiDislikedConclusion,
      'aiDislikedConclusionCount': aiDislikedConclusionCount,
    };
  }

  // Function to create a CrimeFeedback object from JSON
  factory CrimeFeedback.fromJSON(Map<String, dynamic> json) {
    return CrimeFeedback(
      crimeId: json['crimeId'],
      judgeLikedConclusion: (json['judgeLikedConclusion'] as List?)?.cast<String>(),
      judgeLikedConclusionCount: json['judgeLikedConclusionCount'],
      judgeDislikedConclusion: (json['judgeDislikedConclusion'] as List?)?.cast<String>(),
      judgeDislikedConclusionCount: json['judgeDislikedConclusionCount'],
      aiLikedConclusion: (json['aiLikedConclusion'] as List?)?.cast<String>(),
      aiLikedConclusionCount: json['aiLikedConclusionCount'],
      aiDislikedConclusion: (json['aiDislikedConclusion'] as List?)?.cast<String>(),
      aiDislikedConclusionCount: json['aiDislikedConclusionCount'],
    );
  }
}