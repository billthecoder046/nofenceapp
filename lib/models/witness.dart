enum WitnessType {
  anonymous, // Anonymous witness
  identified, // Identified witness
}

class Witness {
  String? id; // Unique ID for the witness
  String? crimeId; // ID of the crime this witness is associated with
  WitnessType? witnessType; // Type of witness (anonymous or identified)
  String? name; // Name of the witness (can be anonymous)
  String? cnic; // CNIC number
  String? mobileNumber; // Mobile number
  String? cnicUrl; // URL of the uploaded CNIC image
  String? profilePicUrl; // URL of the uploaded profile picture
  bool? isReported; // Flag indicating if the witness has been reported
  int? truthCounter; // Counter for users claiming the witness is trustworthy
  int? falseCounter; // Counter for users claiming the witness is not trustworthy
  List<String>? reportedBy; // List of user IDs who reported the witness

  Witness({
    this.id,
    this.crimeId,
    this.witnessType,
    this.name,
    this.cnic,
    this.mobileNumber,
    this.cnicUrl,
    this.profilePicUrl,
    this.isReported = false, // Default is not reported
    this.truthCounter = 0, // Initialize counters to 0
    this.falseCounter = 0,
    this.reportedBy = const [],
  });

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'crimeId': crimeId,
      'witnessType': witnessType?.name, // Store enum as string
      'name': name,
      'cnic': cnic,
      'mobileNumber': mobileNumber,
      'cnicUrl': cnicUrl,
      'profilePicUrl': profilePicUrl,
      'isReported': isReported,
      'truthCounter': truthCounter,
      'falseCounter': falseCounter,
      'reportedBy': reportedBy,
    };
  }

  factory Witness.fromJSON(Map<String, dynamic> json) {
    return Witness(
      id: json['id'],
      crimeId: json['crimeId'],
      witnessType: WitnessType.values.byName(json['witnessType']), // Retrieve enum from string
      name: json['name'],
      cnic: json['cnic'],
      mobileNumber: json['mobileNumber'],
      cnicUrl: json['cnicUrl'],
      profilePicUrl: json['profilePicUrl'],
      isReported: json['isReported'],
      truthCounter: json['truthCounter'],
      falseCounter: json['falseCounter'],
      reportedBy: (json['reportedBy'] as List?)?.cast<String>(),
    );
  }
}