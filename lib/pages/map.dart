import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/map_widget.dart';
import 'package:hiking4nerds/components/shareroute.dart';
import 'package:hiking4nerds/services/elevation_chart.dart'; // needed for testing
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/styles.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();

  MapPage({Key key}) : super(key: key);
}

class MapPageState extends State<MapPage> {
  final GlobalKey<MapWidgetState> mapWidgetKey = GlobalKey<MapWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          MapWidget(
            key: mapWidgetKey,
            isStatic: false
          ),

          //To test the elevation chart
          // Positioned(
          //   top: MediaQuery.of(context).size.height - 450,
          //   left: 10,
          //   height: 200,
          //   width: MediaQuery.of(context).size.width * 0.8,
          //   child: new ElevationChart(
          //     route,
          //     onSelectionChanged: (int index) => print(index),
          //     withLabels: true,
          //      ),
          // ),
          //TODO: remove mock button
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void updateState(HikingRoute route) {
    mapWidgetKey.currentState.drawRoute(route);
  }
}
