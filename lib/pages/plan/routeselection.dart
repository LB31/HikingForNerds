import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/hikingmapbox.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:hiking4nerds/components/calculatingRoutesDialog.dart';
import 'package:location/location.dart';

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

  previousRoute() {
    if (_currentRouteIndex > 0) {
      setState(() {
        _currentRouteIndex = (_currentRouteIndex + -1) % _routes.length;
      });
    }
  }

  Future<void> moveToCurrentLocation() async {
    LocationData currentLocation = await Location().getLocation();
    moveToLatLng(LatLng(currentLocation.latitude, currentLocation.longitude));
  }

  void moveToLatLng(LatLng latLng) {
    mapWidgetKey.currentState.mapController
        .moveCamera(CameraUpdate.newLatLng(latLng));
    mapWidgetKey.currentState.mapController.moveCamera(CameraUpdate.zoomTo(14));
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
          if (_routes.length == 0) CalculatingRoutesDialog(),
          Container(
            color: Theme.of(context).primaryColor,
            width: MediaQuery.of(context).size.width,
            height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                      iconSize: 50,
                      icon: Icon(
                        Icons.arrow_left,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        previousRoute();
                      }),
                  Text("Route $_currentRouteIndex", style: TextStyle(fontSize: 20, color: Colors.white),),
                  IconButton(
                      iconSize: 50,
                      icon: Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        nextRoute();
                      }),
                ],
              ),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width * 0.15,
            bottom: 15,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                heroTag: "btn-gps",
                child: Icon(Icons.gps_fixed),
                onPressed: () {
                  moveToCurrentLocation();
                },
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width * 0.5 - 35,
            child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                heroTag: "btn-search",
                child: Icon(
                  Icons.directions_walk,
                  size: 40,
                ),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
    );
  }
}
