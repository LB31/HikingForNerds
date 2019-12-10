import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MapButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "btn-zoom-in",
              child: Icon(Icons.zoom_in),
              onPressed: () {
                //zoomIn();
              },
            ),
            FloatingActionButton(
              heroTag: "btn-zoom-out",
              child: Icon(Icons.zoom_out),
              onPressed: () {
                //zoomOut();
              },
            ),
            FloatingActionButton(
              heroTag: "btn-navigation",
              child: Icon(Icons.navigation),

//              Icon(_myLocationTrackingMode ==
//                      MyLocationTrackingMode.TrackingCompass
//                  ? Icons.navigation
//                  : OMIcons.navigation),


              onPressed: () {
//                setZoom(15.0);
//                setTrackingMode(MyLocationTrackingMode.TrackingCompass);
              },
            ),
            FloatingActionButton(
              heroTag: "btn-gps",
              child: Icon(Icons.gps_fixed),
              onPressed: () {
                //setTrackingMode(MyLocationTrackingMode.Tracking);
              },
            ),
            FloatingActionButton(
              heroTag: "btn-maptype",
              child: Icon(Icons.terrain),
//
//              Icon(_currentStyle == _styles.keys.first
//                  ? Icons.terrain
//                  : Icons.satellite),
              onPressed: () {
// TODO for now only switching between klokan and bright
//                setMapStyle(_currentStyle == _styles.keys.first
//                    ? _styles.keys.elementAt(1)
//                    : _styles.keys.elementAt(0));
              },
            ),
          ],
        ));
  }
}