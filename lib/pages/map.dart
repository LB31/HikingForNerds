import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/map_widget.dart';
import 'package:hiking4nerds/services/elevation_chart.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';

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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          MapWidget(
            key: mapWidgetKey,
            isStatic: false,
            onElevationChartToggle: toggleHeightChart,
          ),
          if (_currentRoute != null &&
              _currentRoute.elevations != null &&
              _heightChartEnabled)
            _buildElevationChart(context),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildElevationChart(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ElevationChart(
        route: _currentRoute,
        onTouch: (index) {
          mapWidgetKey.currentState.markElevation(index);
        },
        onClose: toggleHeightChart,
      ),
    );
  }

  void toggleHeightChart() {
    this.setState(() {
      _heightChartEnabled = !_heightChartEnabled;
    });
    mapWidgetKey.currentState.toggleHeightChart();
  }

  void updateState(HikingRoute route) {
    _currentRoute = route;
    _heightChartEnabled = false;
    mapWidgetKey.currentState.drawRoute(route);
  }
}
