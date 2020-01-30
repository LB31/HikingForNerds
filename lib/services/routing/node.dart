import 'package:geocoder/geocoder.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class Node extends LatLng{
  int _id;
  int get id => _id;

  Node(this._id, latitude, longitude):
        super(latitude, longitude);

  Node.fromLatLng(LatLng latLng) : super(latLng.latitude, latLng.longitude);

  @override
  bool operator ==(other) => other is Node && other.id ==id;

  @override
  int get hashCode => id;

  @override
  String toString() => "id: $id, lat: $latitude, lng: $longitude";

  Future<Address> findAddress() async {
    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(this.latitude, this.longitude));
    return addresses.first;
  }
}