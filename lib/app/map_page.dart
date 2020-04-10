import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
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

  final Set<Marker> _markers = {};

  LocationData currentLocation;

  Future <LocationData> __changeLocation() async {
    LocationData currentLocation = await PlaceMark().findLocation();
      return currentLocation;
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
      future: __changeLocation(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Center(
                child:CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2.0,
                )
              );
          case ConnectionState.waiting:
            return Center(
                child:CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2.0,
                )
              );
          default:
            if (snapshot.hasError)
              return CircularProgressIndicator();
            else {
              return buildMap(context, snapshot.data);
            }
        }
      },
    );
  }

  MapType _currentMapType = MapType.normal;
  
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Widget buildMap(BuildContext context, LocationData currentLocation) {
    CameraPosition initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude)
    );

    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
         target: LatLng(currentLocation.latitude,
            currentLocation.longitude),
         zoom: CAMERA_ZOOM,
         tilt: CAMERA_TILT,
         bearing: CAMERA_BEARING
      );
    }

    print("MY LOCATION:$currentLocation");
    
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            title: Directionality(
                textDirection: Directionality.of(context),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0
                    ),
                    decoration: InputDecoration(
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0
                        ),
                        border: null
                    ),
                  ),
                )
            ),
          ),
        ),
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
          markers: _markers,
          onMapCreated: _onMapCreated,
          mapType: _currentMapType,
          myLocationEnabled: true,
          compassEnabled: true,
          tiltGesturesEnabled: false,
          initialCameraPosition: initialCameraPosition,
        );
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
        IconButton(icon: Icon(Icons.add_location), onPressed: () => PlaceMark().createRecord()),
        IconButton(icon: Icon(Icons.map), onPressed: _onMapTypeButtonPressed),
      ]
    );
  }
}