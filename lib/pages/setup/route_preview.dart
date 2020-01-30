import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiking4nerds/components/map_widget.dart';
import 'package:hiking4nerds/services/elevation_chart.dart';
import 'package:hiking4nerds/services/localization_service.dart';
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
  final GlobalKey<ElevationChartState> elevationChartWidgetKey = GlobalKey<ElevationChartState>();
  int _drawRouteRetryCounter = 0;
  bool _heightChartEnabled = false;
  List<HikingRoute> _routes = [];
  String _routeAddressLine = LocalizationService()
      .getLocalization(english: 'Loading..', german: 'Lädt..');
  int _currentRouteIndex;

  @override
  void initState() {
    super.initState();
    _routes = widget.routeParams.routes;
    _currentRouteIndex = widget.routeParams.routeIndex;
    _routes[_currentRouteIndex].path.first.findAddress().then((address) {
      _routeAddressLine = address.addressLine;
    });
  }

  void switchRoute(int index) async {
    if (_drawRouteRetryCounter >= 10) {
      _drawRouteRetryCounter = 0;
      return;
    }


      setState(() => _currentRouteIndex = index);
    mapWidgetKey.currentState.drawRoute(_routes[_currentRouteIndex]).then((_) {
      _drawRouteRetryCounter = 0;
    }).catchError((error) {
      new Future.delayed(const Duration(milliseconds: 200), () {
        _drawRouteRetryCounter++;
        switchRoute(index);
      });
    });

    if (_routes[_currentRouteIndex] != null && _heightChartEnabled)
      elevationChartWidgetKey.currentState.updateRoute(_routes[_currentRouteIndex]);
  }

  void switchDirection() {
    List<HikingRoute> updatedRoutes = _routes.map((route) {
      route.path = route.path.reversed.toList();
      return route;
    }).toList();

    setState(() {
      _routes = updatedRoutes;
    });

    mapWidgetKey.currentState.drawRoute(_routes[_currentRouteIndex], false);
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

  void onMapWidgetCreated() {
    switchRoute(_currentRouteIndex);
  }

  Widget _buildElevationChart(BuildContext context, int routeIndex) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ElevationChart(
        key: elevationChartWidgetKey,
        route: _routes[routeIndex],
        onTouch: (index) {
          mapWidgetKey.currentState.markElevation(index);
        },
        onClose: (){this.setState(() {
          _heightChartEnabled = !_heightChartEnabled;
        });},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double routeLength = _routes[_currentRouteIndex].totalLength;
    int avgHikingSpeed = 12; // 12 min per km

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().getLocalization(
            english: 'Route Preview', german: 'Routenvorschau')),
        // TODO add localization
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          MapWidget(
            key: mapWidgetKey,
            isStatic: true,
            mapCreated: onMapWidgetCreated,
          ),
          if (_heightChartEnabled)
            _buildElevationChart(context, _currentRouteIndex),
          if (_routes.length == 0) CalculatingRoutesDialog(),
          Column(children: <Widget>[
            Container(
              color: htwGreen,
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
                  Expanded(
                      child: Card(
                          child: ListTile(
                              onTap: () {},
                              title: Text(_routeAddressLine,
                                  overflow: TextOverflow.ellipsis),
                              subtitle: Text(
                                  "Length: ${routeLength.toStringAsFixed(2)} km - "
                                  "${(routeLength * avgHikingSpeed).toStringAsFixed(0)} min")))),
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
          ]),
          Positioned(
              top: 95,
              left: MediaQuery.of(context).size.width * 0.5 - 65,
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  width: 130,
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.all(Radius.circular(40.0))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text("Start"),
                            new Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: Container(
                                width: 55,
                                height: 5,
                                color: Color.fromARGB(255, 0, 153, 51),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          if (!_heightChartEnabled)
            Stack(
              children: <Widget>[
                Positioned(
                    bottom: 75,
                    left: MediaQuery.of(context).size.width * 0.05,
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: FloatingActionButton(
                          heroTag: "btn-heightchart",
                          child: Icon(Icons.photo),
                          onPressed: () {
                            this.setState(() {
                              _heightChartEnabled = !_heightChartEnabled;
                            });
                          },
                        ))),
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
                  right: MediaQuery.of(context).size.width * 0.05,
                  bottom: 75,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: FloatingActionButton(
                      backgroundColor: htwGrey,
                      heroTag: "btn-center",
                      child: Icon(Icons.center_focus_strong),
                      onPressed: () {
                        mapWidgetKey.currentState
                            .centerCameraOverRoute(_routes[_currentRouteIndex]);
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
                      child: Icon(FontAwesomeIcons.hiking, size: 34),
                      onPressed: (() =>
                          widget.onSwitchToMap(_routes[_currentRouteIndex])),
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}

typedef SwitchToMapCallback = void Function(HikingRoute route);
