import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

abstract class PlaceMarkBase {
  Future<void> createRecord();
  Future<LocationData?> findLocation();
}

class PlaceMark implements PlaceMarkBase {
  final databaseReference = FirebaseFirestore.instance;
  final Location geolocator = Location();

  Future<void> createRecord() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await databaseReference.collection("places").add({
        'user_id': user.uid,
        'location': '0.23,0.24',
        'status': 'created',
        'visits': 0,
        'rating': 0,
        'from': 12,
        'to': 13,
      });
  }

  @override
  Future<LocationData?> findLocation() async {
    var serviceEnabled = await geolocator.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await geolocator.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    var permissionGranted = await geolocator.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await geolocator.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return geolocator.getLocation();
  }
}