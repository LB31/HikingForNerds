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
}