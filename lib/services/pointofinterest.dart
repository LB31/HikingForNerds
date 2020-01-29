import 'package:hiking4nerds/services/database_helpers.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/routing/poi_category.dart';

class PointOfInterest extends Node {
  Map<String, dynamic> tags;
  PoiCategory category;

  PointOfInterest(int id, double latitude, double longitude, this.tags)
      : super(id, latitude, longitude) {
    var categories = PoiCategory.categories.where((cat) => cat.id == getCategoryString());
    if (categories != null && categories.length > 0) {
      category = categories.first;
    }
  }

  String getCategoryString() =>
      tags.containsKey("amenity") ? tags["amenity"] : tags["tourism"];

  factory PointOfInterest.fromMap(Map<String, dynamic> map) {
    DatabaseHelper dbh = DatabaseHelper.instance;
    return PointOfInterest(map[dbh.columnPoiId], map[dbh.columnLat], map[dbh.columnLng], null);
  }

  Map<String, dynamic> toMap(int routeid) {
    DatabaseHelper dbh = DatabaseHelper.instance;
    var map = <String, dynamic>{
      dbh.columnRouteId: routeid,
      dbh.columnPoiId: id,
      dbh.columnLat: latitude,
      dbh.columnLng: longitude,
    };
    return map;
  }
}