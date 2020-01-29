import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:hiking4nerds/styles.dart';

class MapButtons extends StatelessWidget {
  //Why do these variables exist? check out: https://stackoverflow.com/a/51033284/5630207
  const MapButtons(
      {this.currentTrackingMode,
      this.styles,
      this.currentStyle,
      this.onCycleTrackingMode,
      this.setMapStyle,
      this.centerRoute});

  final MyLocationTrackingMode currentTrackingMode;
  final VoidCallback onCycleTrackingMode;
  final VoidCallback centerRoute;

  final String currentStyle;
  final Map<String, String> styles;
  final SetMapStyleCallback setMapStyle;

  Icon getTrackingModeIcon() {
    switch (currentTrackingMode) {
      case MyLocationTrackingMode.None:
        return Icon(OMIcons.navigation);
      case MyLocationTrackingMode.Tracking:
        return Icon(Icons.navigation);
      case MyLocationTrackingMode.TrackingCompass:
        return Icon(Icons.rotate_90_degrees_ccw);
      default:
        return Icon(OMIcons.navigation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: MediaQuery.of(context).size.width * 0.05,
          bottom: 16,
          child: SizedBox(
            width: 50,
            height: 50,
            child: FloatingActionButton(
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
          ),
        ),
        Positioned(
          right: MediaQuery.of(context).size.width * 0.05,
          bottom: 16,
          child: SizedBox(
            width: 50,
            height: 50,
            child: FloatingActionButton(
                heroTag: "btn-gps",
                child: getTrackingModeIcon(),
                onPressed: onCycleTrackingMode),
          ),
        ),
        Positioned(
          right: MediaQuery.of(context).size.width * 0.05,
          bottom: 75,
          child: SizedBox(
            width: 50,
            height: 50,
            child: FloatingActionButton(
              backgroundColor: htwGrey,
              heroTag: "btn-center",
              child: Icon(Icons.center_focus_weak),
              onPressed: () {
                centerRoute();
              },
            ),
          ),
        ),
      ],
    );
  }
}

typedef SetMapStyleCallback = void Function(String style);
