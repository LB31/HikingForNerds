import 'package:hiking4nerds/services/routing/node.dart';
import 'package:flutter/material.dart';

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

  Color getColorFromCategory(){
    String category = getCategory();
    return getColorFromString(category);
  }

  Color getColorFromString(String abbr){
    return colorFromAbbr(abbr.toUpperCase());
  }

  Color colorFromAbbr(String abbr){
    int r = letterToRGBValue(abbr.substring(0, 1));
    int g = letterToRGBValue(abbr.substring(1, 2));
    int b = letterToRGBValue(abbr.substring(2, 3));
    return Color.fromARGB(255, r, g, b);
  }

  int letterToRGBValue(String letter){
    return (letter.substring(0, 1).codeUnitAt(0) - 65) * 10;
  }

}