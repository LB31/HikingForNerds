import 'package:geocoder/geocoder.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';

class HikingRoute {
  List<Node> path; //path of route
  double totalLength; // routeLength in km
  List<PointOfInterest> pointsOfInterest;
  List<double> elevations; // elevations of route points in m; route points and their elevations have the same index
  DateTime date; // date created

  HikingRoute (List<Node> path, double totalLength, [List<PointOfInterest> pointsOfInterest, List<double> elevations]) {
    this.path = path;
    this.totalLength = totalLength;
    this.pointsOfInterest = pointsOfInterest;
    this.elevations = elevations;
    this.date = DateTime.now();
  }

  Future<Address> findAddress() async {
    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(this.path.first.latitude, path.first.longitude));
    return addresses.first;
  }
}