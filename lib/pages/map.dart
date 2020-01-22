import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/map_widget.dart';
import 'package:hiking4nerds/components/shareroute.dart';
import 'package:hiking4nerds/services/elevation_chart.dart'; // needed for testing
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

  bool _heightChartEnabled = false;
  HikingRoute _currentRoute;

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
          MapWidget(key: mapWidgetKey, isStatic: false),
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
          FloatingActionButton(
            heroTag: "btn-heightchart",
            child: Icon(Icons.photo),
            onPressed: toggleHeightChartMode,
          ),
          if(_currentRoute != null && _heightChartEnabled)
            _buildElevationChart(context),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildElevationChart(BuildContext context){
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            width: 300,
            height: 150,
            child: ElevationChart(
              _currentRoute,
              onSelectionChanged: mapWidgetKey.currentState.markElevation,
              interactive: true,
            )
        )
    );
  }

  void toggleHeightChartMode(){
    mapWidgetKey.currentState.removeSelectedElevation();
    this.setState((){
      _heightChartEnabled = !_heightChartEnabled;
    });
  }

  void updateState(HikingRoute route) {
    _currentRoute = route;
    _heightChartEnabled = false;
    mapWidgetKey.currentState.drawRoute(route);
  }
}
