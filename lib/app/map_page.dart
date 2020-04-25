import 'dart:async';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/place.dart';
import 'package:my_events/app/event_create.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:my_events/common_widgets/animated_loading.dart';
import 'package:location/location.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(42.747932,-71.167889);
const LatLng DEST_LOCATION = LatLng(37.335685,-122.0605916);

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

  final Set<Marker> _markers = {};

  LocationData _currentLocation;

  bool futureCompleted;

  Future <LocationData> __changeLocation() async {
    LocationData currentLocation = await PlaceMark().findLocation();
      futureCompleted = true;
      setState(() {
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
        floatingActionButton: __placeMarkButton(),
      );
  }

  GoogleMap __showMap(context, initialCameraPosition){
    return GoogleMap(
          onTap: _handleTap,
          markers: _markers,
          onMapCreated: _onMapCreated,
          mapType: _currentMapType,
          myLocationEnabled: true,
          compassEnabled: true,
          tiltGesturesEnabled: false,
          initialCameraPosition: initialCameraPosition,
        );
  }

  void _handleTap(LatLng point) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: 'I am a marker',
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ));
    });
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  FabCircularMenu __placeMarkButton()
  {
    return FabCircularMenu(
      ringColor: Colors.white70,
      alignment: Alignment.bottomRight,
      children: <Widget>[
        IconButton(icon: Icon(Icons.location_searching), onPressed: ()=>PlaceMark().findLocation()),
        //IconButton(icon: Icon(Icons.add_location), onPressed: () => PlaceMark().createRecord()),
        IconButton(icon: Icon(Icons.add_location), onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => EventCreate(auth: auth),
            ),
          )
        ),
        IconButton(icon: Icon(Icons.map), onPressed: _onMapTypeButtonPressed),
      ]
    );
  }
}