import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import '../services/types.dart';
import 'package:hiking4nerds/services/map_service.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  MapController mc = MapController();
  MapService ms = MapService();

  @override
  Widget build(BuildContext context) {
    LatLng mapLocation = ms.getMapLatLong();
    TileLayerOptions tileLayerOptions = ms.getTileLayerOptions(tl: TileLayerType.hike);
    PolylineLayerOptions polylineLayerOptions = ms.getPolyLineLayerOptions();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hiking 4 Nerds'),
        backgroundColor: Color(0xff76B900),
      ),
      body: FlutterMap(
        mapController: this.mc,
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
    );
  }
}
