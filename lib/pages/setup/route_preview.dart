import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/map_widget.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:hiking4nerds/components/calculate_routes_dialog.dart';
import 'package:location/location.dart';
import 'package:hiking4nerds/services/routeparams.dart';

class RoutePreviewPage extends StatefulWidget {
  final SwitchToMapCallback onSwitchToMap;
  final RouteParams routeParams;

  @override
  _RoutePreviewPageState createState() => _RoutePreviewPageState();

  RoutePreviewPage(
      {Key key, @required this.onSwitchToMap, @required this.routeParams})
      : super(key: key);
}

class _RoutePreviewPageState extends State<RoutePreviewPage> {
  final GlobalKey<MapWidgetState> mapWidgetKey = GlobalKey<MapWidgetState>();

  List<HikingRoute> _routes = [];
  int _currentRouteIndex;

  @override
  void initState() {
    super.initState();
    _routes = widget.routeParams.routes;
    _currentRouteIndex = widget.routeParams.routeIndex;

    Future.delayed(const Duration(milliseconds: 2000), () {
      switchRoute(_currentRouteIndex);
    });
  }

  void switchRoute(int index) {
    setState(() => _currentRouteIndex = index);
    mapWidgetKey.currentState.drawRoute(_routes[_currentRouteIndex]);
  }

  void switchDirection() {
    List<HikingRoute> updatedRoutes = _routes.map((route) {
      route.path = route.path.reversed.toList();
      return route;
    }).toList();

    setState(() {
      _routes = updatedRoutes;
    });

    mapWidgetKey.currentState.drawRoute(_routes[_currentRouteIndex]);
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
      appBar: AppBar(
        title: Text('Route Preview'), // TODO add localization
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      ),
      body: Stack(
        children: <Widget>[
          MapWidget(
            key: mapWidgetKey,
            isStatic: true,
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
                    onPressed: () => switchRoute(
                        (_currentRouteIndex + (_routes.length - 1)) %
                            _routes.length)),
                Text(
                  "Route ${_currentRouteIndex + 1}",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                IconButton(
                    iconSize: 50,
                    icon: Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    ),
                    onPressed: () => switchRoute(
                        (_currentRouteIndex + (_routes.length + 1)) %
                            _routes.length)),
              ],
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            bottom: 16,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                backgroundColor: htwGrey,
                heroTag: "btn-switch-direction",
                child: Icon(Icons.swap_horizontal_circle),
                onPressed: () {
                  switchDirection();
                },
              ),
            ),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width * 0.05,
            bottom: 16,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                backgroundColor: htwGrey,
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
                backgroundColor: htwGreen,
                heroTag: "btn-go",
                child: Icon(
                  Icons.directions_walk,
                  size: 36,
                ),
                onPressed: (() =>
                    widget.onSwitchToMap(_routes[_currentRouteIndex])),
              ),
            ),
          ),
          Positioned(
              top: 85,
              left: MediaQuery.of(context).size.width * 0.5 - 65,
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  width: 130,
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(40.0))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text("Start"),
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: Container(
                                width: 60,
                                height: 5,
                                color: Colors.green,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text("Finish"),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                width: 60,
                                height: 5,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

typedef SwitchToMapCallback = void Function(HikingRoute route);
