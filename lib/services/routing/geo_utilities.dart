import 'dart:math';

import 'package:hiking4nerds/services/routing/node.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

double getDistance(LatLng nodeA, LatLng nodeB){
//optimized haversine formular from https://stackoverflow.com/questions/27928/calculate-distance-between-two-latitude-longitude-points-haversine-formula
var p = 0.017453292519943295;    // PI / 180
var a = 0.5 - cos((nodeB.latitude - nodeA.latitude) * p)/2 + cos(nodeA.latitude* p) * cos(nodeB.latitude* p) * (1 - cos((nodeB.longitude - nodeA.longitude) * p))/2;
return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
}

// http://www.movable-type.co.uk/scripts/latlong.html
double getBearing(Node nodeA, Node nodeB){
var lat1 = toRadians(nodeA.latitude);
var lat2 = toRadians(nodeB.latitude);
var lon1 = toRadians(nodeA.longitude);
var lon2 = toRadians(nodeB.longitude);
var y = sin(lon2 - lon1) * cos(lat2);
var x = cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(lon2-lon1);
var rad = atan2(y, x);
return (toDegrees(rad) + 360) % 360;
}

double toRadians(double angleInDeg){
return (angleInDeg*pi)/180.0;
}

double toDegrees(double angleInRad){
return (angleInRad*180.0)/pi;
}

List<double> projectCoordinate(double latInDeg, double longInDeg, double distanceInM, double headingFromNorth){
  var latInRadians = toRadians(latInDeg);
  var longInRadians = toRadians(longInDeg);
  var headingInRadians = toRadians(headingFromNorth);

  double angularDistance = distanceInM / 6371000.0;

  // This formula is taken from: http://williams.best.vwh.net/avform.htm#LL
  // (http://www.movable-type.co.uk/scripts/latlong.html -> https://github.com/chrisveness/geodesy  ->  https://github.com/graphhopper/graphhopper Apache 2.0)
  // θ=heading,δ=distance,φ1=latInRadians
  // lat2 = asin( sin φ1 ⋅ cos δ + cos φ1 ⋅ sin δ ⋅ cos θ )
  // lon2 = λ1 + atan2( sin θ ⋅ sin δ ⋅ cos φ1, cos δ − sin φ1 ⋅ sin φ2 )
  double projectedLat = asin(sin(latInRadians) * cos(angularDistance)
      + cos(latInRadians) * sin(angularDistance) * cos(headingInRadians));
  double projectedLon = longInRadians + atan2(sin(headingInRadians) * sin(angularDistance) * cos(latInRadians),
      cos(angularDistance) - sin(latInRadians) * sin(projectedLat));

  projectedLon = (projectedLon + 3 * pi) % (2 * pi) - pi; // normalise to -180..+180°

  projectedLat = projectedLat * 180/pi;
  projectedLon = projectedLon * 180/pi;

  return [projectedLat, projectedLon];
}
