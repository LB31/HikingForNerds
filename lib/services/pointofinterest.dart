import 'package:hiking4nerds/services/routing/node.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
class PointOfInterest extends Node {
  Map<String, dynamic> tags;

  PointOfInterest(int id, double latitude, double longitude, this.tags)
      : super(id, latitude, longitude);

  String getCategory() {
    var category = "";
    if (tags.containsKey("amenity")) {
      category = tags["amenity"];
    } else {
      category = tags["tourism"];
    }
    return category;
  }

  String getColorString() {
    String category = getCategory();
    return stringToColourString(category);
  }

  /*Javascript code adapted to dart: from https://stackoverflow.com/a/16348977*/
  String stringToColourString(String str) {
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }
    String colour = '#';
    for (var i = 0; i < 3; i++) {
      var value = (hash >> (i * 8)) & 0xFF;
      colour += ('' + value.toRadixString(16));
    }
    return colour; 
  }

  CircleOptions getCircleOptions(){
    return CircleOptions(
        geometry: LatLng(latitude, longitude),
        circleColor: getColorString(),
        circleRadius: 3,
        circleBlur: 0.25,
        circleOpacity: 0.8);
  }

  SymbolOptions getSymbolOptions(){
    String category = getCategory();
    //iconColor:  getColorString(),

    String iconPath = getIconPath(category);
    return SymbolOptions(iconImage: iconPath, geometry: LatLng(latitude, longitude), iconSize: 0.1);
  }

  getIconPath(String category){
    return "assets/img/symbols/$category.png";
  }

}
