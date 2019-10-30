import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'types.dart';

class Map extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MapState();
  }
}

class MapState extends State<Map> {
  LocationData _currentUserLocation;
  TileLayerOptions _tileLayerOptions;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    updateStateOnLocationChange();
  }

  Future<LocationData> getCurrentLocation() async {
    LocationData currentLocation;

    var location = new Location();

// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();

      print("getCurrentLocation --> " + currentLocation.toString());

      setState(() {
        this._currentUserLocation = currentLocation;
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        String error = 'Permission denied';
        print(error);
      }
      currentLocation = null;
    }
    return currentLocation;
  }

  void updateStateOnLocationChange() {
    var location = new Location();

    location.onLocationChanged().listen((LocationData currentLocation) {

      print("location has changed!");

      print(currentLocation.latitude);
      print(currentLocation.longitude);

      setState(() {
        this._currentUserLocation = currentLocation;
      });

    });
  }

  TileLayerOptions getTileLayerOptions({TileLayerType tl = TileLayerType.normal}) {

    TileLayerOptions options;

    switch (tl) {
      case TileLayerType.hike:
        options = TileLayerOptions(
            urlTemplate: "https://tiles.wmflabs.org/hikebike/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']);
        break;
      case TileLayerType.topography:
        options = TileLayerOptions(
            urlTemplate: "http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']);
        break;
      case TileLayerType.monochrome:
        options = TileLayerOptions(
            urlTemplate:
            "http://www.toolserver.org/tiles/bw-mapnik/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']);
        break;
      default:
        options = TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']);
    }

    return options;
  }

  LatLng getMapLatLong(){
    LatLng mapLocation;
    if(_currentUserLocation != null){
      mapLocation = new LatLng(_currentUserLocation.latitude, _currentUserLocation.longitude);

    } else {
      mapLocation = new LatLng(52.52, 13.4);
    }
    return mapLocation;
  }

  @override
  Widget build(BuildContext context) {

    LatLng mapLocation = getMapLatLong();
    TileLayerOptions tileLayerOptions = getTileLayerOptions(tl:TileLayerType.hike); 

    return new FlutterMap(
      options: new MapOptions(center: mapLocation),
      layers: [
        tileLayerOptions,
        new MarkerLayerOptions(markers: [
          new Marker(
              width: 45.0,
              height: 45.0,
              point: mapLocation,
              builder: (context) => Container(
                    child: IconButton(
                        icon: Icon(Icons.accessibility),
                        onPressed: () {
                          print('Marker tapped!');
                        }),
                  ))
        ])
      ],
    );
  }
}
