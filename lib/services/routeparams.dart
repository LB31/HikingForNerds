import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/routing/poi_category.dart';
import 'package:hiking4nerds/services/route.dart';

import 'localization_service.dart';

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
        return LocalizationService().getLocalization(english: "N/A", german: "n. a.");
      case AltitudeType.minimal:
        return LocalizationService().getLocalization(english: "minimal", german: "minimal");
      case AltitudeType.high:
        return LocalizationService().getLocalization(english: "high", german: "hoch");
    }

    return "";
  }

  static AltitudeType fromIndex(int index) {
    return AltitudeType.values[index];
  }

  static AltitudeType differenceToType(double difference, int routeLength) {
    double localDifference = difference / routeLength;
    if (localDifference > 1.5) {
      return AltitudeType.high;
    }

    return AltitudeType.minimal;
  }
}

class RouteParams {
  Node startingLocation;
  double distanceKm;
  List<PoiCategory> poiCategories;
  AltitudeType altitudeType;
  double altitude;
  List<HikingRoute> routes;
  int routeIndex;

  RouteParams(this.startingLocation, [this.distanceKm, this.poiCategories, this.altitudeType, this.altitude]);
}
