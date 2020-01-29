import 'package:geocoder/geocoder.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/database_helpers.dart';

class HikingRoute {
  int dbId;
  List<Node> path; //path of route
  double totalLength; // routeLength in km
  List<PointOfInterest> pointsOfInterest;
  List<double>
      elevations; // elevations of route points in m; route points and their elevations have the same index
  DateTime date; // date created

  HikingRoute(List<Node> path, double totalLength,
      [List<PointOfInterest> pointsOfInterest, List<double> elevations, int dbId]) {
    this.dbId = dbId;
    this.path = path;
    this.totalLength = totalLength;
    this.pointsOfInterest = pointsOfInterest;
    this.elevations = elevations;
    this.date = DateTime.now();
  }

  Future<Address> findAddress() async {
    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(this.path.first.latitude, path.first.longitude));
    return addresses.first;
  }
  
  double getTotalElevationDifference(){
    var totalElevationDifference = 0.0;
    for(int i = 1; i<elevations.length; i++){
      totalElevationDifference += (elevations[i] - elevations[i-1]).abs();
    }
    return totalElevationDifference;
  }

  static Future<HikingRoute> fromMap(Map<String, dynamic> map) async{
    DatabaseHelper dbh = DatabaseHelper.instance;
    List<Node> path = await getPathFromDb(dbh, map[dbh.columnId]);
    double totalLength = map[dbh.columnLength];
    return HikingRoute(path, totalLength);
  }

  static Future<List> getPathFromDb(DatabaseHelper dbh, int id) async {
    List<Node> path = await dbh.queryPath(id);
    return path;
  }

  Map<String, dynamic> toMap() {
    DatabaseHelper dbh = DatabaseHelper.instance;
    var map = <String, dynamic>{
      dbh.columnId: dbId,
      dbh.columnLength: totalLength,
      dbh.columnDate: date.toString(),
    };
    if (dbId != null) {
      map[dbh.columnId] = dbId;
    }
    return map;
  }
}