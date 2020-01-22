
import 'package:hiking4nerds/services/routing/node.dart';

class PointOfInterest extends Node{
  Map<String, dynamic> tags;

  PointOfInterest(int id, double latitude, double longitude, this.tags) : super(id, latitude, longitude);

  String getCategory(){
    var category = "";
    if(tags.containsKey("amenity")) {
      category = tags["amenity"];
    }
    else {
      category = tags["tourism"];
    }
    return category;
  }
}