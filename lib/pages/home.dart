import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/map_widget.dart';
import 'package:hiking4nerds/components/shareroute.dart';
import 'package:hiking4nerds/services/elevation_chart.dart'; // needed for testing
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';

// TODO rename to map
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    HikingRoute route = new HikingRoute([
      Node(0, 52.510318, 13.4085592),
      Node(1, 52.5102903, 13.4084606),
      Node(2, 52.5101514, 13.4081806),
      Node(3, 52.507592, 13.409908),
    ], 50, null, [3.3, 2.1, 50.2, 20.8]);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          MapWidget(isStatic: false),
          //To test the elevation chart
          // Positioned(
          //   top: MediaQuery.of(context).size.height - 450,
          //   left: 10,
          //   height: 200,
          //   width: MediaQuery.of(context).size.width * 0.8,
          //   child: new ElevationChart(
          //     route,  
          //     onSelectionChanged: (int index) => print(index),
          //     withLabels: false,
          //      ),
          // ),
          //TODO: remove mock button
          Align(
            alignment: Alignment.bottomRight,
            child: RawMaterialButton(
              onPressed: () {
                HikingRoute mockRoute = route;

                showDialog(
                    context: context,
                    builder: (BuildContext context) => ShareRoute(
                          route: mockRoute,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.find_replace),
        backgroundColor: htwGreen,
        elevation: 2.0,
      ),
    );
  }
}
