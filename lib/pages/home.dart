import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:hiking4nerds/services/types.dart';
import 'package:hiking4nerds/services/map_service.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Color htwGreen = Color(0xff76B900);
  MapService ms = MapService();

  @override
  Widget build(BuildContext context) {
    LatLng mapLocation = ms.getMapLatLong();
    TileLayerOptions tileLayerOptions = ms.getTileLayerOptions(tl: TileLayerType.hike);
    PolylineLayerOptions polylineLayerOptions = ms.getPolyLineLayerOptions();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hiking 4 Nerds'),
        backgroundColor: htwGreen,
      ),
      body: FabCircularMenu(
        child: FlutterMap(
          mapController: ms.mapController,
          options: MapOptions(center: mapLocation),
          layers: [
            tileLayerOptions,
            polylineLayerOptions,
            MarkerLayerOptions(markers: [
              Marker(
                width: 45.0,
                height: 45.0,
                point: mapLocation,
                builder: (context) => Container(
                  child: IconButton(
                  icon: Icon(
                    Icons.accessibility,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    print('Marker tapped!');
                  }),
                ))
              ]),
            ],
          ),
        ringColor: Colors.white30,
        fabColor: htwGreen,
        options: <Widget>[
          IconButton(icon: Icon(
            Icons.help_outline), onPressed: () {}, iconSize: 48.0, color: htwGreen),
          IconButton(icon: Icon(Icons.save_alt), onPressed: () {}, iconSize: 48.0, color: htwGreen),
          IconButton(icon: Icon(Icons.map), onPressed: () {}, iconSize: 48.0, color: htwGreen),
          IconButton(icon: Icon(Icons.info_outline), onPressed: () {}, iconSize: 48.0, color: htwGreen),
        ],
      ),
    );
  }
}
