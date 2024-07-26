import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationBloc extends ChangeNotifier {
  LatLng? currentLocation;
  bool _isLoadingLocation = false;

  bool get isLoadingLocation => _isLoadingLocation;

  // Function to get the user's current location
  Future<Map<String, dynamic>> getCurrentLocation(context) async {
    LatLng? selectedLocation;
    TextEditingController locationController = TextEditingController();
    try {
      // Check if location permission is granted
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Show alert dialog if location permission is not granted
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                  'This app needs access to your location to report a crime. Please grant permission.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Open app settings to allow location access
                    Geolocator.openAppSettings();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Settings'),
                ),
              ],
            );
          },
        );
      } else {
        // Get location if permission is granted
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        print("Abdullah ${position.latitude }");
        // Get the address using placemarkFromCoordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        print("Idrees placemarks: $placemarks");
        String? address = "${placemarks.first.street}, ${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}";


          selectedLocation = LatLng(position.latitude, position.longitude);
          // Update the location controller with the full address
          locationController.text = address??"Could not get address";

        return {'controller': locationController, 'loc': selectedLocation};

      }
    } catch (e) {
      print('Error getting location: $e');
    }
    return {};
  }

// Function to fetch data within a radius of the current location
// (This is an example, adapt it to your specific needs)
// Future<List<dynamic>> fetchNearbyData(double radius) async {
//   try {
//     if (currentLocation == null) {
//       // Handle case where location is not available
//       return [];
//     }
//
//     final geoFirestore = maps.GeoFirestore.instance;
//     final query = geoFirestore.collection('your_collection_name').within(
//       center: GeoPoint(currentLocation!.latitude, currentLocation!.longitude),
//       radius: radius,
//       field: 'location', // Make sure you have a 'location' GeoPoint field in your collection
//     );
//     final querySnapshot = await query.get();
//     return querySnapshot.docs.map((doc) => doc.data()).toList();
//   } catch (e) {
//     print('Error fetching nearby data: $e');
//     return [];
//   }
// }
}
