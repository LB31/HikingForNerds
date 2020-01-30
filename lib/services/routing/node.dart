import 'package:geocoder/geocoder.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:hiking4nerds/services/database_helpers.dart';

class Node extends LatLng{
  int _id;
  int get id => _id;

  Node(this._id, latitude, longitude) : super(latitude, longitude);

  Node.fromLatLng(LatLng latLng) : super(latLng.latitude, latLng.longitude);

  @override
  bool operator ==(other) => other is Node && other.id == id;

  @override
  int get hashCode => id;

  @override
  String toString() => "id: $id, lat: $latitude, lng: $longitude";

  Future<Address> findAddress() async {
    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(this.latitude, this.longitude));
    return addresses.first;
  }

  factory Node.fromMap(Map<String, dynamic> map) {
    DatabaseHelper dbh = DatabaseHelper.instance;
    return Node(map[dbh.columnNodeId], map[dbh.columnLat], map[dbh.columnLng]);
  }

  Map<String, dynamic> toMap(int routeid) {
    DatabaseHelper dbh = DatabaseHelper.instance;
    var map = <String, dynamic>{
      dbh.columnRouteId: routeid,
      dbh.columnNodeId: _id,
      dbh.columnLat: latitude,
      dbh.columnLng: longitude,
    };
    return map;
  }
}
