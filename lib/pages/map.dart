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
    HikingRoute route = new HikingRoute([
      Node(0, 52.510318, 13.4085592),
      Node(1, 52.5102903, 13.4084606),
      Node(2, 52.5101514, 13.4081806),
      Node(3, 52.507592, 13.409908),
    ], 50,
        [
          new PointOfInterest(0, 52.5102903, 13.4084606,
              {
                "highway": "bus_stop",
                "name": "Main Street"
              }
          ),
          new PointOfInterest(0, 52.507592, 13.409908,
              {
                "name": "Just another Street"
              }
          )
        ],
        [3.3, 2.1, 50.2, 20.8]
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          MapWidget(key: mapWidgetKey, isStatic: false),
//          //To test the elevation chart
//           Positioned(
//             top: MediaQuery.of(context).size.height - 450,
//             left: 10,
//             height: 200,
//             width: MediaQuery.of(context).size.width * 0.8,
//             child: new ElevationChart(
//               route,
//               onSelectionChanged: (int index) => print(index),
//               withLabels: false,
//                ),
//           ),
          //TODO: remove mock button
          Align(
            alignment: Alignment.bottomRight,
            child: RawMaterialButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => ShareRoute(
                          route: route,
                        ));
              },
              child: Icon(
                Icons.share,
                color: Colors.black,
                size: 36.0,
              ),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: htwGreen,
              padding: const EdgeInsets.all(5.0),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void updateState(HikingRoute route) {
    mapWidgetKey.currentState.drawRoute(route);
  }
}
