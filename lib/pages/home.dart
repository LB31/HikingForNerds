import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/map_widget.dart';
import 'package:hiking4nerds/components/shareroute.dart';
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';

// TODO rename to map
class Home extends StatefulWidget {
  final HikingRoute route;
  final VoidCallback onPushHistory;


  @override
  _HomeState createState() => _HomeState();

  Home({Key key, this.route, this.onPushHistory}) : super(key: key);
}

class _HomeState extends State<Home> {
  final GlobalKey<MapWidgetState> mapWidgetKey =
  new GlobalKey<MapWidgetState>();

  onMapReady(){
    if(widget.route != null) {
      mapWidgetKey.currentState.drawRoute(widget.route);
      mapWidgetKey.currentState.initUpdateRouteTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          MapWidget(key: mapWidgetKey, isStatic: false, onMapReady: onMapReady,),
          //TODO: remove mock button
          Align(
            alignment: Alignment.bottomRight,
            child: RawMaterialButton(
              onPressed: () {
                HikingRoute mockRoute = HikingRoute([
                  Node(0, 52.510318, 13.4085592),
                  Node(1, 52.5102903, 13.4084606),
                  Node(2, 52.5101514, 13.4081806)
                ], 2);

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
