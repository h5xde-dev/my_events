import 'dart:async';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/place.dart';
import 'package:my_events/app/event_create.dart';
import 'package:my_events/app/event_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:my_events/common_widgets/custom_marker.dart' as customMarker;
import 'package:my_events/common_widgets/animated_loading.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

class MapPage extends StatefulWidget {
  MapPage({
    @required this.auth
  });

  final AuthBase auth;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  _MapPageState({
      this.auth
  });

  final AuthBase auth;

  Set<Marker> _markers = {};

  LocationData _currentLocation;

  bool futureCompleted;

  Future<Set> getData() async {
    Set<Marker> markers = {};
    await Firestore.instance
        .collection("places")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
          createMarker(f) async {
            markers.add(
              Marker(
                markerId: MarkerId(f.documentID),
                position: LatLng(f.data['latitude'] , f.data['longitude']),
                icon: await customMarker.getMarkerIcon("images/image_01.png", Size(150.0, 150.0), context),
                onTap: (){
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventPage(auth: auth, data: f.data)
                        ),
                    );
                }
              )
            );
            setState(() {
              _markers = markers;
            });
          }
          snapshot.documents.forEach((f) => createMarker(f));
        });
    return markers;
  }

  Future <LocationData> __changeLocation() async {
    LocationData currentLocation = await PlaceMark().findLocation();
      futureCompleted = true;
      Set<Marker> markers = {};
      markers = await getData();
      setState(() {
        _markers = markers;
        _currentLocation = currentLocation;
      });
      return currentLocation;
  }

  @override
  Widget build(BuildContext context){
    if(futureCompleted == true)
    {
      return AnimatedBackground(
        child: buildMap(context),
      );

    } else
    {
      return FutureBuilder(
        future: __changeLocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          switch (snapshot.connectionState) {
          case ConnectionState.none:
            return AnimatedLoading();
          case ConnectionState.waiting:
            return AnimatedLoading();
          default:
            if (snapshot.hasError)
              return AnimatedLoading();
            else {
              return AnimatedBackground(
                child: buildMap(context),
              );
            }
          }
        },
      );
    }
  }

  MapType _currentMapType = MapType.normal;
  
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Widget buildMap(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(_currentLocation.latitude, _currentLocation.longitude)
    );

    if (_currentLocation != null) {
      initialCameraPosition = CameraPosition(
         target: LatLng(_currentLocation.latitude,
            _currentLocation.longitude),
         zoom: CAMERA_ZOOM,
         tilt: CAMERA_TILT,
         bearing: CAMERA_BEARING
      );
    }
    
    return Scaffold(
        body: __buildContent(context, initialCameraPosition),
      );
  }

  Scaffold __buildContent(context, initialCameraPosition) {
    return Scaffold(
        body: __showMap(context, initialCameraPosition),
      );
  }

  GoogleMap __showMap(context, initialCameraPosition){
    return GoogleMap(
          onTap: _handleTap,
          markers: _markers,
          onMapCreated: _onMapCreated,
          mapType: _currentMapType,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          compassEnabled: true,
          tiltGesturesEnabled: false,
          initialCameraPosition: initialCameraPosition,
        );
  }

  void _handleTap(LatLng point) {
    
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EventCreate(auth: auth, place: point,),
          ),
    );
    /* setState(() {
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: 'I am a marker',
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ));
    }); */
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  FloatingActionButton __placeMarkButton()
  {
    return FloatingActionButton(
      onPressed: _onMapTypeButtonPressed,
    );
  }
}