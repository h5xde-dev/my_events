import 'dart:async';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(42.747932,-71.167889);
const LatLng DEST_LOCATION = LatLng(37.335685,-122.0605916);

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.auth});

  final AuthBase auth;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Set<Marker> _markers = {};
  final PlaceMark _placeMark = PlaceMark();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationData?>(
      future: _placeMark.findLocation(),
      builder: (BuildContext context, AsyncSnapshot<LocationData?> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }
        return buildMap(context, snapshot.data);
      },
    );
  }

  MapType _currentMapType = MapType.normal;
  
  final Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Widget buildMap(BuildContext context, LocationData? currentLocation) {
    CameraPosition initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(
        currentLocation?.latitude ?? SOURCE_LOCATION.latitude,
        currentLocation?.longitude ?? SOURCE_LOCATION.longitude,
      ),
    );

    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
         target: LatLng(
           currentLocation.latitude ?? SOURCE_LOCATION.latitude,
           currentLocation.longitude ?? SOURCE_LOCATION.longitude,
         ),
         zoom: CAMERA_ZOOM,
         tilt: CAMERA_TILT,
         bearing: CAMERA_BEARING
      );
    }
    
    return Scaffold(
        body: _buildContent(context, initialCameraPosition),
      );
  }

  Scaffold _buildContent(BuildContext context, CameraPosition initialCameraPosition) {
    return Scaffold(
        body: _showMap(context, initialCameraPosition),
        floatingActionButton: _placeMarkButton(),
      );
  }

  GoogleMap _showMap(BuildContext context, CameraPosition initialCameraPosition) {
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

  Widget _placeMarkButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'locate',
          onPressed: () => _placeMark.findLocation(),
          child: const Icon(Icons.location_searching),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'add_location',
          onPressed: () => _placeMark.createRecord(),
          child: const Icon(Icons.add_location),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'map_type',
          onPressed: _onMapTypeButtonPressed,
          child: const Icon(Icons.map),
        ),
      ],
    );
  }
}