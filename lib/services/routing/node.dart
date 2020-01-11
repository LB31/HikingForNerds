import 'package:mapbox_gl/mapbox_gl.dart';

//dummy class to be able to run code without importing mapbox which only works with flutter
//with this class this code can be run without flutter
//class LatLng{
//  double latitude;
//  double longitude;
//  LatLng(this.latitude, this.longitude);
//}

class Node extends LatLng{
  int _id;
  int get id => _id;

  Node(this._id, latitude, longitude):
        super(latitude, longitude);


  @override
  bool operator ==(other) => other is Node && other.id ==id;

  @override
  int get hashCode => id;

  @override
  String toString() => "id: $id, lat: $latitude, lng: $longitude";
}