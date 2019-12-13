import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapButtons extends StatelessWidget {

  //Why do these variables exist? check out: https://stackoverflow.com/a/51033284/5630207
  const MapButtons({this.currentTrackingMode, this.styles, this.currentStyle, this.cycleTrackingMode, this.setMapStyle});
  final MyLocationTrackingMode currentTrackingMode;
  final String currentStyle;
  final Map<String, String> styles;
  final VoidCallback cycleTrackingMode;
  final SetMapStyleCallback setMapStyle;

  Icon getTrackingModeIcon() {
    switch (currentTrackingMode) {
      case MyLocationTrackingMode.None:
        {
          return Icon(OMIcons.navigation);
        }
        break;
      case MyLocationTrackingMode.Tracking:
        {
          return Icon(Icons.navigation);
        }
        break;
      case MyLocationTrackingMode.TrackingCompass:
        {
          return Icon(Icons.rotate_90_degrees_ccw);
        }
        break;
      default:
        {
          return Icon(OMIcons.navigation);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "btn-gps",
              child: getTrackingModeIcon(),
              onPressed: cycleTrackingMode
            ),
            FloatingActionButton(
              heroTag: "btn-maptype",
              child: Icon(currentStyle == styles.keys.first
                  ? Icons.terrain
                  : Icons.satellite),
              onPressed: () {
                // TODO for now only switching between klokan and bright
                setMapStyle(currentStyle == styles.keys.first
                    ? styles.keys.elementAt(1)
                    : styles.keys.elementAt(0));
              },
            ),
          ],
        ));
  }
}

typedef SetMapStyleCallback = void Function(String style);
