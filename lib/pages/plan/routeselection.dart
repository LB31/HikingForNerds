import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/hikingmapbox.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:hiking4nerds/components/calculatingRoutesDialog.dart';


class RouteSelection extends StatefulWidget {
  final LatLng routeStartingLocation;

  @override
  _RouteSelectionState createState() => _RouteSelectionState();

  RouteSelection({Key key, @required this.routeStartingLocation})
      : super(key: key);
}

class _RouteSelectionState extends State<RouteSelection> {
  final GlobalKey<MapWidgetState> mapWidgetKey =
      new GlobalKey<MapWidgetState>();

  List _routes = [];
  int _currentRouteIndex = 0;

  @override
  initState() {
    super.initState();
    calculateRoutes();
  }

  calculateRoutes() async {
    var osmData = OsmData();
    var routes = await osmData.calculateRoundTrip(
        widget.routeStartingLocation.latitude,
        widget.routeStartingLocation.longitude,
        10000,
        10); 

    setState(() {
      _routes = routes;
      _currentRouteIndex = 0;
    });
  }

  nextRoute() {
    setState(() {
      _currentRouteIndex = (_currentRouteIndex + 1) % _routes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          if (_routes.length > 0)
            MapWidget(
              key: mapWidgetKey,
              isStatic: true,
              route: _routes.length > 0 ? _routes[_currentRouteIndex] : null,
            ),
          if (_routes.length == 0) CalculatingRoutesDialog()
          ],
      ),
    );
  }
}
