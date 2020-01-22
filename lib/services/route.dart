import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:intl/intl.dart';
import 'package:geocoder/geocoder.dart';
import 'package:mapbox_gl/mapbox_gl.dart';


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
    setTitle(''); // TODO get region or custom info as title
  }

  Future<String> buildTitle() async{
   List<Address> results = await Geocoder.local.findAddressesFromCoordinates(Coordinates(path[0].latitude, path[0].longitude));
   return '${results[0].thoroughfare}, ${results[0].locality}';
  }

  void setTitle(String title) {
    if(title == '') this.title = 'Sample Title'; // get Adress from GeoData
    else this.title = title;
  }
}
