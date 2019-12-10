import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/hikingmapbox.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class LocationSelection extends StatefulWidget {
  @override
  _LocationSelectionState createState() => _LocationSelectionState();
}

class _LocationSelectionState extends State<LocationSelection> {
  LatLng _location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          MapWidget(
            isStatic: true,
          ),
          Center(
              child: Icon(
            Icons.person_pin_circle,
            color: Colors.red,
            size: 50,
          )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.directions_walk),
        onPressed: (){
          setState(() {
            _location = null;
          });
        },
      ),
    );
  }
}
