import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:crimebook/models/all_crime_models/criminals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UserType {
  judge,
  lawyer,
  witness,
  crimeReporter,
  ordinaryperson
}
enum UserGender {
  male,
  female
}

class MyUser {
  String? uid; // Firebase Authentication UID
  String? name;
  String? email;
  String? cnicNo;
  UserGender? gender;
  String? phoneNumber;
  // String? cnicUrl;
  String? profilePicUrl;
  DateTime? cnicDob;
  DateTime? cnicIssueDate;
  DateTime? cnicExpiryDate;
  UserType? userType;

  MyUser({
    this.uid,
    this.name,
    this.email,
    this.cnicNo,
    this.gender,
    this.phoneNumber,
    this.profilePicUrl,
    this.cnicDob,
    this.cnicIssueDate,
    this.cnicExpiryDate,
    this.userType,
  });

  Map<String, dynamic> toJSON() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'cnicNo': cnicNo,
      'gender':gender?.name,
      'phoneNumber': phoneNumber,
      'profilePicUrl': profilePicUrl,
      'cnicDob': cnicDob?.millisecondsSinceEpoch,
      'cnicIssueDate': cnicIssueDate?.millisecondsSinceEpoch,
      'cnicExpiryDate': cnicExpiryDate?.millisecondsSinceEpoch,
      'userType': userType?.name, // Store enum as string
    };
  }

  factory MyUser.fromJSON(Map<String, dynamic> json) {
    return MyUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      gender: UserGender.values.byName(json['gender']),
      phoneNumber: json['phoneNumber'],
      cnicNo: json['cnicNo'],
      profilePicUrl: json['profilePicUrl'],
      cnicDob: json['cnicDob'] != null ? DateTime.fromMillisecondsSinceEpoch(json['cnicDob']) : null,
      cnicIssueDate: json['cnicIssueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['cnicIssueDate']) : null,
      cnicExpiryDate: json['cnicExpiryDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['cnicExpiryDate']) : null,
      userType: UserType.values.byName(json['userType']), // Retrieve enum from string
    );
  }
}