import 'package:mapbox_gl/mapbox_gl.dart';


enum AltitudeType{
  none,
  minimal,
  high,
}

class RouteParams {

  LatLng startingLocation;
  double distance;
  List<String> poi;
  AltitudeType altitudeType;

  //todo: add height information

  RouteParams(this.startingLocation, [this.distance, this.poi, this.altitudeType]);
}


