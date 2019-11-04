import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class Map extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MapState();
  }
}

class MapState extends State<Map> {
  LocationData currentUserLocation;

  @override
  void initState() {
    super.initState();
    print("initState");
    getCurrentLocation();
  }

  Future<LocationData> getCurrentLocation() async {
    LocationData currentLocation;

    var location = new Location();

// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();

      print("getCurrentLocation --> " + currentLocation.toString());

      setState(() {
        this.currentUserLocation = currentLocation;
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

  void onLocationChanged() {
    var location = new Location();

    location.onLocationChanged().listen((LocationData currentLocation) {
      print(currentLocation.latitude);
      print(currentLocation.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {

    LatLng mapLocation;
    if(currentUserLocation != null){
      mapLocation = new LatLng(currentUserLocation.latitude, currentUserLocation.longitude);

    } else {
      mapLocation = new LatLng(52.52, 13.4);
    }

    print("build --> " + mapLocation.toString());

    /*return new FlutterMap(
      options: new MapOptions(center: mapLocation),
      layers: [
        new TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c']),
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
    );*/

    return new FlutterMap(
      options: MapOptions(
        center: LatLng(52.520008, 13.404954),
        minZoom: 10.0,
        maxZoom: 14.0,
        zoom: 10.0,
        swPanBoundary: LatLng(52.396149, 13.058540),
        nePanBoundary: LatLng(52.680859, 13.583550),
      ),
      layers: [
        TileLayerOptions(
          tileProvider: AssetTileProvider(),
          maxZoom: 14.0,
          urlTemplate: 'assets/map/berlin/{z}/{x}/{y}.png',
        ),
      ],
    );

  }
}
