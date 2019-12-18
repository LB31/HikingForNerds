import 'package:hiking4nerds/services/osmdata.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';


class HikingRoute {
  List<Node> path; //path of route
  double totalLength; // routeLength in km
  List<PointOfInterest> pointsOfInterest;
  //todo: add height information
  List<double> elevations; // elevations of route points in m; route points and their elevations have the same index

  HikingRoute(this.path, this.totalLength, [this.pointsOfInterest]);

}
