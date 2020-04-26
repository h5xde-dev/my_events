import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'dart:async';

abstract class PlaceMarkBase {
  createRecord(
    Map formData,
    LatLng place,
  );
}

class PlaceMark implements PlaceMarkBase{

  final databaseReference = Firestore.instance;

  Future<void> createRecord(
    Map formData,
    LatLng place
  ) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await databaseReference.collection("places")
      .add({
        'user_id': user.uid,
        'longitude': place.longitude,
        'latitude': place.latitude,
        'name': formData['eventName'],
        'description':formData['eventDescription'],
        'address':formData['eventAddress'],
        'startDay':formData['eventDay'],
        'startMonth':formData['eventMonth'],
        'startHour':formData['eventHours'],
        'startMinute':formData['eventMinutes'],
        'endDay':formData['eventEndDay'],
        'endMonth':formData['eventEndMonth'],
        'endHour':formData['eventEndHours'],
        'endMinute':formData['eventEndMinutes'],
        'status':'created',
        'visits': 0,
        'rating': 0,
      });
  }



  Location geolocator = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Future<QuerySnapshot> getAllDocuments() {
    return databaseReference.collection('places').getDocuments();
  }

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