import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/hikingmapbox.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';

class LocationSelection extends StatefulWidget {
  @override
  _LocationSelectionState createState() => _LocationSelectionState();
}

class _LocationSelectionState extends State<LocationSelection> {

  final GlobalKey<MapWidgetState> mapWidgetKey = new GlobalKey<MapWidgetState>();
  LatLng _location;

  Future<void> moveToCurrentLocation() async {
    LocationData currentLocation = await Location().getLocation();
    mapWidgetKey.currentState.mapController.moveCamera(CameraUpdate.newLatLng(LatLng(currentLocation.latitude, currentLocation.longitude)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          MapWidget(
            key: mapWidgetKey,
            isStatic: true,
          ),
          Center(
              child: Icon(
            Icons.person_pin_circle,
            color: Colors.red,
            size: 50,
          )),
          Positioned(
            right: 5,
            top: MediaQuery.of(context).size.height * 0.5,
            child: FloatingActionButton(
              heroTag: "btn-gps",
              child: Icon(Icons.gps_fixed),
              onPressed: (){
                moveToCurrentLocation();
              },
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.directions_walk),
        onPressed: (){
          setState(() {
            _location = mapWidgetKey.currentState.mapController.cameraPosition.target;
          });
        },
      ),
    );
  }
}
