import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapButtons extends StatelessWidget {
  //Why do these variables exist? check out: https://stackoverflow.com/a/51033284/5630207
  const MapButtons(
      {this.currentTrackingMode,
      this.styles,
      this.currentStyle,
      this.onCycleTrackingMode,
      this.setMapStyle,
      this.onElevationChartToggle});

  final MyLocationTrackingMode currentTrackingMode;
  final VoidCallback onCycleTrackingMode;
  final VoidCallback onElevationChartToggle;

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
            bottom: 66,
            left: MediaQuery.of(context).size.width * 0.05,
            child: SizedBox(
                width: 50,
                height: 50,
                child:FloatingActionButton(
                  heroTag: "btn-heightchart",
                  child: Icon(Icons.photo),
                  onPressed: onElevationChartToggle,
                )
            )
        ),
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
      ],
    );
  }
}

typedef SetMapStyleCallback = void Function(String style);
