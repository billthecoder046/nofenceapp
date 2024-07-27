import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:nofence/models/all_crime_models/criminals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UserType {
  judge,
  lawyer,
  witness,
  crimeReporter,
}

class MyUser {
  String? uid; // Firebase Authentication UID
  String? name;
  String? email;
  String? password;
  String? cnic;
  String? phoneNumber;
  String? cnicUrl;
  String? profilePicUrl;
  UserType? userType;

  MyUser({
    this.uid,
    this.name,
    this.email,
    this.password,
    this.cnic,
    this.phoneNumber,
    this.cnicUrl,
    this.profilePicUrl,
    this.userType,
  });

  Map<String, dynamic> toJSON() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'cnic': cnic,
      'phoneNumber': phoneNumber,
      'cnicUrl': cnicUrl,
      'profilePicUrl': profilePicUrl,
      'userType': userType?.name, // Store enum as string
    };
  }

  factory MyUser.fromJSON(Map<String, dynamic> json) {
    return MyUser(
      uid: json['uid'],
      name: json['name'],
      password: json['password'],
      email: json['email'],
      cnic: json['cnic'],
      phoneNumber: json['phoneNumber'],
      cnicUrl: json['cnicUrl'],
      profilePicUrl: json['profilePicUrl'],
      userType: UserType.values.byName(json['userType']), // Retrieve enum from string
    );
  }
}