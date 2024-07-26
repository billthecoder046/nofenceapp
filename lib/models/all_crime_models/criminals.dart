

class Criminal {
  String? id; // Optional: To store document ID from Firebase
  String? name;
  List<String>? imageUrls;// Name of the criminal
  String? nic;
  String? nickName; // Alias or nickname (optional)
  String? description; // Detailed description of the criminal (optional)
  DateTime? dateOfBirth; // Date of birth (optional)
  String? gender; // Gender (optional)
  String? nationality; // Nationality (optional)
  String? address; // Address (optional)
  List<String>? associatedCrimeIds; // List of crime IDs associated with this criminal
  List<String>? associatedWitnessIds; // List of witness IDs who have seen or know this criminal
  List<String>? associatedEvidenceIds; // List of evidence IDs linked to this criminal
  String? status; // E.g., "arrested", "wanted", "free"

  Criminal({
    this.id,
    this.name,

    this.nic,
    this.nickName,
    this.description,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.address,
    this.imageUrls,
    this.associatedCrimeIds,
    this.associatedWitnessIds,
    this.associatedEvidenceIds,
    this.status,
  });

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'imageUrls':imageUrls,
      'nic':nic,
      'nickName': nickName,
      'description': description,
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
      'gender': gender,
      'nationality': nationality,
      'address': address,
      'associatedCrimeIds': associatedCrimeIds,
      'associatedWitnessIds': associatedWitnessIds,
      'associatedEvidenceIds': associatedEvidenceIds,
      'status': status,
    };
  }

  factory Criminal.fromJSON(Map<String, dynamic> json) {
    return Criminal(
      id: json['id'],
      name: json['name'],
      nic: json['nic'],
      imageUrls: json['imageUrls'],
      nickName: json['nickName'],
      description: json['description'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.fromMillisecondsSinceEpoch(json['dateOfBirth']) : null,
      gender: json['gender'],
      nationality: json['nationality'],
      address: json['address'],
      associatedCrimeIds: (json['associatedCrimeIds'] as List?)?.cast<String>(),
      associatedWitnessIds: (json['associatedWitnessIds'] as List?)?.cast<String>(),
      associatedEvidenceIds: (json['associatedEvidenceIds'] as List?)?.cast<String>(),
      status: json['status'],
    );
  }
}