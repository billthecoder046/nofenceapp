import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:crimebook/models/all_crime_models/crime.dart';
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../config/firebase_config.dart';
import 'ciminal_bloc.dart'; // Import FirebaseConfig

class CrimeBloc extends ChangeNotifier {
  // State variables to hold data
  Crime? currentCrime;

  // Data lists
  List<Crime> crimes = [];
  // ... (other lists for judges, witnesses, etc.)

  // Pagination variables for each data type
  QueryDocumentSnapshot? _lastCrimeVisible;
  // ... (other pagination variables)

  // Loading states for each data type
  bool _isLoadingCrimes = true;
  // ... (other loading states)

  // Getters for loading states
  bool get isLoadingCrimes => _isLoadingCrimes;

  // --- Crime Operations ---

  Future<void> refreshCrimes(BuildContext context) async {
    _isLoadingCrimes = true;
    await fetchAllCrimes(refresh: true);
    notifyListeners();
  }

  Future<void> createCrime(Crime newCrime) async {
    try {
      print("Gonna create Crime");
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimesCollection).doc();
      newCrime.id = docRef.id;
      print("doc Ref is: ${docRef.toString()}");
      print("nadf ${newCrime.toJSON()}");
      await docRef.set(newCrime.toJSON()).then((value) => print("saved succesfully"));
      crimes.add(newCrime);
      notifyListeners();
    } catch (e) {
      print('Error creating crime: $e');
    }
  }

  Future<void> getCrime(String crimeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimesCollection).doc(crimeId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        currentCrime = Crime.fromJSON(docSnapshot.data()!);
        notifyListeners();
      }
    } catch (e) {
      print('Error getting crime: $e');
    }
  }

  Future<void> updateCrime(Crime updatedCrime) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimesCollection).doc(updatedCrime.id);
      await docRef.update(updatedCrime.toJSON());
      // Update the crime in the list if it exists
      final index = crimes.indexWhere((crime) => crime.id == updatedCrime.id);
      if (index != -1) {
        crimes[index] = updatedCrime;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating crime: $e');
    }
  }

  Future<void> deleteCrime(String crimeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimesCollection).doc(crimeId);
      await docRef.delete();
      // Remove the crime from the list
      crimes.removeWhere((crime) => crime.id == crimeId);
      notifyListeners();
    } catch (e) {
      print('Error deleting crime: $e');
    }
  }

  Future<void> fetchAllCrimes({bool refresh = false}) async {


      // Clear existing data if refreshing
      if (refresh) {
        crimes.clear();
        _lastCrimeVisible = null;
      }

      _isLoadingCrimes = true; // Set loading state to true before fetching

      QuerySnapshot rawData;
      if (_lastCrimeVisible == null) {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.crimesCollection)
            .orderBy('postDate', descending: true)
            .limit(4)
            .get();
      } else {
        rawData = await FirebaseFirestore.instance
            .collection(FirebaseConfig.crimesCollection)
            .orderBy('postDate', descending: true)
            .startAfter([_lastCrimeVisible!['postDate']])
            .limit(4)
            .get();
      }
      print("My raw data length is: ${rawData.toString()}");

      if (rawData.docs.length > 0) {
        print("Raw data length is greater than 0");
        _lastCrimeVisible = rawData.docs[rawData.docs.length - 1];
        crimes.addAll(rawData.docs.map((doc) => Crime.fromJSON(doc.data() as Map<String,dynamic>)).toList());
        _isLoadingCrimes = false; // Set loading state to false after fetching
        notifyListeners();
      } else {
        print("Raw data length is less than 0");
        _isLoadingCrimes = false; // Set loading state to false even if no more data
        print('No more crimes available');
        notifyListeners();
      }

  }

  // --- Criminal Operations ---

  // Add a criminal to a crime
  Future<void> addCriminalToCrime(String crimeId, String criminalId, {required CriminalBloc criminalBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimesCollection).doc(crimeId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final crime = Crime.fromJSON(docSnapshot.data()!);
        if (!crime.criminalIds!.contains(criminalId)) {
          crime.criminalIds!.add(criminalId);
          await docRef.update(crime.toJSON());
          // Update associated criminals
          await criminalBloc.addAssociatedCrime(criminalId, crimeId);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error adding criminal to crime: $e');
    }
  }
  Future<List<Crime>> getCrimesByLocation(double latitude, double longitude, double radius, context) async {
    try {
      final geoFirestore = Provider.of<GeoFirestore>(context, listen: false); // Get GeoFirestore instance
      final queryLocation = GeoPoint(latitude, longitude);

      // Use the getAtLocation method for GeoFirestore queries
      final List<DocumentSnapshot> documents = await geoFirestore.getAtLocation(queryLocation, radius);

      return documents.map((document) => Crime.fromJSON(document.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching crimes by location: $e');
      return [];
    }
  }
  Future<void> setCrimeLocation(String crimeId, double latitude, double longitude,context) async {
    try {
      final geoFirestore = Provider.of<GeoFirestore>(context, listen: false); // Get GeoFirestore instance

      // Set location using GeoFirestore
      await geoFirestore.setLocation(crimeId, GeoPoint(latitude, longitude));
    } catch (e) {
      print('Error setting crime location: $e');
    }
  }

  // Function to remove a crime's location using GeoFirestore
  Future<void> removeCrimeLocation(String crimeId, geoPoint, context) async {
    try {
      final geoFirestore = Provider.of<GeoFirestore>(context, listen: false); // Get GeoFirestore instance

      // Remove location using GeoFirestore
      await geoFirestore.removeLocation(crimeId, geoPoint);
    } catch (e) {
      print('Error removing crime location: $e');
    }
  }

  // Remove a criminal from a crime
  Future<void> removeCriminalFromCrime(String crimeId, String criminalId, {required CriminalBloc criminalBloc}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(FirebaseConfig.crimesCollection).doc(crimeId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final crime = Crime.fromJSON(docSnapshot.data()!);
        if (crime.criminalIds!.contains(criminalId)) {
          crime.criminalIds!.remove(criminalId);
          await docRef.update(crime.toJSON());
          // Update associated criminals
          await criminalBloc.removeAssociatedCrime(criminalId, crimeId);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error removing criminal from crime: $e');
    }
  }


  // Find a crime by its type
  Future<List<Crime>> getCrimesByType(String crimeType) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseConfig.crimesCollection)
          .where('crimeType', isEqualTo: crimeType)
          .get();
      return querySnapshot.docs.map((doc) => Crime.fromJSON(doc.data())).toList();
    } catch (e) {
      print('Error fetching crimes by type: $e');
      return [];
    }
  }

  // Find a crime by its category
  Future<List<Crime>> getCrimesByCategory(CrimeType crimeCategory) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseConfig.crimesCollection)
          .where('crimeCategory', isEqualTo: crimeCategory.name)
          .get();
      return querySnapshot.docs.map((doc) => Crime.fromJSON(doc.data())).toList();
    } catch (e) {
      print('Error fetching crimes by category: $e');
      return [];
    }
  }

  //Posted by User

}