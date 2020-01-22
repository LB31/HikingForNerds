import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:intl/intl.dart';
import 'package:geocoder/geocoder.dart';

class HikingRoute {
  List<Node> path; //path of route
  double totalLength; // routeLength in km
  List<PointOfInterest> pointsOfInterest;
  //todo: add height information
  List<double> elevations; // elevations of route points in m; route points and their elevations have the same index
  String date; // date created
  String title; // (custom) route title

  // HikingRoute(this.path, this.totalLength, [this.pointsOfInterest, this.elevations]);
  
  HikingRoute (List<Node> path, double totalLength, [List<PointOfInterest> pointsOfInterest, List<double> elevations]) {
    this.path = path;
    this.totalLength = totalLength;
    this.pointsOfInterest = pointsOfInterest;
    this.elevations = elevations;
    this.date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    setTitle('');
  }

  Future<String> buildTitle() async{
   List<Address> results = await Geocoder.local.findAddressesFromCoordinates(Coordinates(path[0].latitude, path[0].longitude));
   String street = (results[0].thoroughfare != null) ? results[0].thoroughfare : '';
   String city = (results[0].locality.length + results[0].thoroughfare.length > 20) ? '\n' : ', ';
   city += (results[0].locality != null) ? results[0].locality : '';
   return '$street$city';
  }

  void setTitle(String title) {
    this.title = title;
  }
}