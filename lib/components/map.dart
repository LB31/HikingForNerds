import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
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
  MapController _mapController;
  bool _autoCenter;

  @override
  void initState() {
    super.initState();

    _currentUserLocation = null;
    _mapController = new MapController();
    _autoCenter = false;

    updateCurrentLocation();
    updateCurrentLocationOnChange();
  }

  Future<void> updateCurrentLocation() async {
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
    }
  }

  void updateCurrentLocationOnChange() {
    var location = new Location();

    location.onLocationChanged().listen((LocationData currentLocation) {
      print("location has changed!");

      print(currentLocation.latitude);
      print(currentLocation.longitude);

      setState(() {
        this._currentUserLocation = currentLocation;
      });

      if (this._autoCenter) {
        centerOnPosition(currentLocation);
      }

    });
  }

  TileLayerOptions getTileLayerOptions(
      {TileLayerType tl = TileLayerType.normal}) {
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

  PolylineLayerOptions getPolyLineLayerOptions(){
    var points = <LatLng>[
      LatLng(52.5, 13.455),
      LatLng(52.5, 13.46),
      LatLng(52.5, 13.47),
      LatLng(52.52, 13.48),
      LatLng(52.53, 13.49),
      LatLng(52.53, 13.48),
      LatLng(52.57, 13.5),
      LatLng(52.58, 13.5),
      LatLng(52.59, 13.51),
      LatLng(52.5, 13.5),
      LatLng(52.5, 13.455),
    ];

    var points2 = <LatLng>[
      LatLng(52.5, 13.455),
      LatLng(52.53, 13.458),
      LatLng(52.54, 13.459),
      LatLng(52.58, 13.459),
      LatLng(52.58, 13.5),
      LatLng(52.7, 13.55),
    ];


    PolylineLayerOptions polylineLayerOptions = new PolylineLayerOptions(
      polylines: [
        Polyline(points: points, strokeWidth: 4.0, color: Colors.purple),
        Polyline(points: points2, strokeWidth: 4.0, color: Colors.green),
      ],
    );

    return polylineLayerOptions;

  }

  LatLng getMapLatLong() {
    LatLng mapLocation;
    if (this._currentUserLocation != null) {
      mapLocation = new LatLng(this._currentUserLocation.latitude,
          this._currentUserLocation.longitude);
    } else {
      mapLocation = new LatLng(52.52, 13.4);
    }
    return mapLocation;
  }

  Future<void> centerOnPosition(LocationData locationData) async {
    LatLng center = new LatLng(locationData.latitude, locationData.longitude);
    this._mapController.move(center, this._mapController.zoom);
  }

  @override
  Widget build(BuildContext context) {
    LatLng mapLocation = getMapLatLong();
    TileLayerOptions tileLayerOptions =
    getTileLayerOptions(tl: TileLayerType.hike);
    PolylineLayerOptions polylineLayerOptions = getPolyLineLayerOptions();

    return new FlutterMap(
      mapController: this._mapController,
      options: new MapOptions(center: mapLocation),
      layers: [
        tileLayerOptions,
        polylineLayerOptions,
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
        ]),
      ],
    );
  }
}
