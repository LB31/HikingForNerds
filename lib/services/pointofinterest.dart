import 'osmdata.dart';

class PointOfInterest extends Node{
  Map<String, dynamic> tags;

  PointOfInterest(int id, double latitude, double longitude, this.tags) : super(id, latitude, longitude);
}