import 'package:geocoder/geocoder.dart';
import 'package:hiking4nerds/services/routeparams.dart';
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
  AltitudeType altitudeType;
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

  getAltitudeType () {
    return AltitudeTypeHelper.differenceToType( getTotalElevationDifference(), path.length );
  }

  Future<Address> findAddress() async {
    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(this.path.first.latitude, path.first.longitude));
    return addresses.first;
  }
  
  double getTotalElevationDifference(){
    var totalElevationDifference = 0.0;
    for(int i = 1; i < elevations.length; i++){
      totalElevationDifference += (elevations[i] - elevations[i-1]).abs();
    }
    return totalElevationDifference;
  }

  static Future<HikingRoute> fromMap(Map<String, dynamic> map) async {
    DatabaseHelper dbh = DatabaseHelper.instance;
    int id = map[dbh.columnId];
    List<Node> path = await getPathFromDb(dbh, id);
    double totalLength = map[dbh.columnLength];
    List<PointOfInterest> pois = await getPoisFromDb(dbh, id);
    List<double> elevations = await getElevationsFromDb(dbh, id);
    return HikingRoute(path, totalLength, pois, elevations, id);
  }

  static Future<List> getPathFromDb(DatabaseHelper dbh, int id) async {
    List<Node> path = await dbh.queryPath(id);
    return path;
  }

  static Future<List> getPoisFromDb(DatabaseHelper dbh, int id) async {
    List<PointOfInterest> pois = await dbh.queryPois(id);
    return pois;
  }

  static Future<List> getElevationsFromDb(DatabaseHelper dbh, int id) async {
    List<double> elevations = await dbh.queryElevations(id);
    return elevations;
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