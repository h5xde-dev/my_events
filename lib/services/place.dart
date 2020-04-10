import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'dart:async';

abstract class PlaceMarkBase {
  createRecord();
}

class PlaceMark implements PlaceMarkBase{

  final databaseReference = Firestore.instance;

  Future<void> createRecord() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print(user.uid);
    await databaseReference.collection("places")
      .add({
        'user_id': user.uid,
        'location': '0.23,0.24',
        'status':'created',
        'visits': 0,
        'rating': 0,
        'from': 12,
        'to':13,
      });
  }

  Location geolocator = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Future findLocation() async {
    _serviceEnabled = await geolocator.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await geolocator.requestService();
        if (!_serviceEnabled) {
        
        }
      }

    _permissionGranted = await geolocator.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await geolocator.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          
        }
      }
    _locationData = await geolocator.getLocation();
    
    return _locationData;
  }
}