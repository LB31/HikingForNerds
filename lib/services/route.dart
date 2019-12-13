
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';

class HikingRoute {

  List<Node> path; //path of route
  double totalLength; // routeLength in km
  List<PointOfInterest> pointsOfInterest;
  //todo: add height information

  HikingRoute(this.path, this.totalLength, [this.pointsOfInterest]);
}