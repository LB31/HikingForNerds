
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

  String getColorFromCategory(){
    String category = getCategory();

    switch(category) {
      case "architecture": {
        return "White";
      }
      break;
      case "bar": {
        return "Red";
      }
      break;
      case "basilica": {
        return "Green";
      }
      break;
      case "cathedral": {
        return "Yellow";
      }
      break;
      case "chruch": {
        return "Yellow";
      }
      break;
      case "exhibition": {
        return "Brown";
      }
      break;
      case "gas station": {
        return "Black";
      }
      break;
      case "lake, monuments": {
        return "Blue";
      }
      break;
      case "museum": {
        return "Brown";
      }
      break;
      case "park": {
        return "Green";
      }
      break;
      case "river": {
        return "Blue";
      }
      break;
      case "romanic": {
        return "Red";
      }
      break;
      case "school": {
        return "Blue";
      }
      break;
      case "zoo": {
        return "Pink";
      }
      break;
      default: {
        return "Green";
      }
      break;
    }
  }
}