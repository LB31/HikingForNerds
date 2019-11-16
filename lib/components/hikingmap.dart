import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:hiking4nerds/components/types.dart';
import 'package:hiking4nerds/osmdata.dart';

class HikingMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HikingMapState();
  }
}

class HikingMapState extends State<HikingMap> {
  LocationData currentUserLocation;
  PolylineLayerOptions polylineLayerOptions;
  MapController mapController;
  bool autoCenter;

  @override
  void initState() {
    super.initState();

    currentUserLocation = null;
    mapController = MapController();
    autoCenter = false;
    this.polylineLayerOptions = getPolyLineLayerOptions();

    updateCurrentLocation();
    updateCurrentLocationOnChange();
    initTestRoute();
  }

  Future<void> updateCurrentLocation() async {
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
    }
  }

  void updateCurrentLocationOnChange() {
    var location = Location();

    location.onLocationChanged().listen((LocationData currentLocation) {
      print("location has changed!");

      print(currentLocation.latitude);
      print(currentLocation.longitude);

      setState(() {
        this.currentUserLocation = currentLocation;
      });

      if (this.autoCenter) {
        centerOnPosition(currentLocation);
      }
    });
  }

  Future<void> initTestRoute() async{
    var osmData = OsmData();
    var route = await osmData.calculateRoundTrip(52.510143, 13.408564, 10000, 90);
    var routeLatLng = route.map((node) => LatLng(node.latitude, node.longitude)).toList();
    var polyLineLayerOptions = new PolylineLayerOptions(
    polylines: [
    Polyline(points: routeLatLng, strokeWidth: 4.0, color: Colors.pink, isDotted: true),
    ],);
    setState(() {
      this.polylineLayerOptions = polyLineLayerOptions;
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

  PolylineLayerOptions getPolyLineLayerOptions() {
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


    var polylineLayerOptions = new PolylineLayerOptions(
      polylines: [
        Polyline(points: points, strokeWidth: 4.0, color: Colors.purple),
        Polyline(points: points2, strokeWidth: 4.0, color: Colors.green),
      ],
    );

    return polylineLayerOptions;
  }

  LatLng getMapLatLong() {
    LatLng mapLocation;
    if (this.currentUserLocation != null) {
      mapLocation = LatLng(this.currentUserLocation.latitude,
          this.currentUserLocation.longitude);
    } else {
      mapLocation = LatLng(52.52, 13.4);
    }
    return mapLocation;
  }

  Future<void> centerOnPosition(LocationData locationData) async {
    LatLng center = LatLng(locationData.latitude, locationData.longitude);
    this.mapController.move(center, this.mapController.zoom);
  }

  @override
  Widget build(BuildContext context) {
    LatLng mapLocation = getMapLatLong();
    TileLayerOptions tileLayerOptions =
        getTileLayerOptions(tl: TileLayerType.hike);
//    PolylineLayerOptions polylineLayerOptions = getPolyLineLayerOptions();

    return FlutterMap(
      mapController: this.mapController,
      options: MapOptions(center: mapLocation),
      layers: [
        tileLayerOptions,
        this.polylineLayerOptions,
        MarkerLayerOptions(markers: [
          Marker(
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
