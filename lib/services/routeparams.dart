import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:hiking4nerds/services/route.dart';

typedef RouteParamsCallback = void Function(RouteParams routeParams);

enum AltitudeType {
  none,
  minimal,
  high,
}

class AltitudeTypeHelper {
  static String asString(AltitudeType type) {
    switch (type) {
      case AltitudeType.none:
        return "N/A";
      case AltitudeType.minimal:
        return "minimal";
      case AltitudeType.high:
        return "high";
    }

    return "";
  }

  static AltitudeType fromIndex(int index) {
    return AltitudeType.values[index];
  }
}

class RouteParams {
  LatLng startingLocation;
  double distanceKm;
  List<String> poiCategories;
  AltitudeType altitudeType;
  List<HikingRoute> routes;
  int routeIndex;

  RouteParams(this.startingLocation, [this.distanceKm, this.poiCategories, this.altitudeType]);
}
