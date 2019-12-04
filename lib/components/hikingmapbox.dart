import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:location/location.dart';
import 'dart:async';

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final CameraPosition _cameraInitialPos;
  final CameraTargetBounds _cameraTargetBounds;
  static double defaultZoom = 12.0;

  bool _isLoadingRoute = false;
  List _routes = [];
  int _currentRouteIndex = 0;
  List<LatLng> _passedRoute = [];
  List<LatLng> _route = [];
  Line _lineRoute;
  Line _linePassedRoute;

  LocationData _currentDeviceLocation;
  Timer _timer;

  CameraPosition _position;
  MapboxMapController mapController;
  bool _compassEnabled = true;
  bool _isMoving = false;
  MinMaxZoomPreference _minMaxZoomPreference =
      const MinMaxZoomPreference(0.0, 22.0);
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool _tiltGesturesEnabled = true;
  bool _zoomGesturesEnabled = true;
  bool _myLocationEnabled = true;
  bool _tilesLoaded = false;
  String _currentStyle;
  Map<String, String> _styles = new Map();
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.Tracking;

  _MapWidgetState._(
      this._cameraInitialPos, this._position, this._cameraTargetBounds);

  factory _MapWidgetState() {
    CameraPosition cameraPosition = _getCameraPosition();

    // get bounds for areas at https://boundingbox.klokantech.com/
    // bounds germany
    final countryBounds = LatLngBounds(
      southwest: LatLng(47.27, 5.87),
      northeast: LatLng(55.1, 15.04),
    );

    return _MapWidgetState._(
        cameraPosition, cameraPosition, CameraTargetBounds(countryBounds));
  }

  @override
  initState() {
    super.initState();

    _loadOfflineTiles().then((result) => {
          requestLocationPermissionIfNotAlreadyGranted().then((result) {
            getCurrentLocation().then((location) {
              initRoutes();
            });
            updateCurrentLocationOnChange();
          })
        });
  }

  Future<void> _loadOfflineTiles() async {
    try {
      _styles["klokan-tech"] =
          await _loadJson('assets/styles/klokan-tech.json');
      _styles["bright-osm"] = await _loadJson('assets/styles/bright-osm.json');
      _currentStyle = _styles.keys.first;
      await installOfflineMapTiles("assets/offline-data/berlin_klokan-tech.db");
    } catch (err) {
      print(err);
    }
    setState(() {
      this._tilesLoaded = true;
    });
  }

  Future<String> _loadJson(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<LocationData> getCurrentLocation() async {
    LocationData currentLocation;
    var location = new Location();
    currentLocation = await location.getLocation();
    setState(() {
      this._currentDeviceLocation = currentLocation;
    });
    return currentLocation;
  }

  void updateCurrentLocationOnChange() {
    Location location = Location();
    location.onLocationChanged().listen((LocationData currentLocation) {
      setState(() {
        _currentDeviceLocation = currentLocation;
      });
    });
  }

  Future<void> initRoutes() async {
    setState(() {
      _isLoadingRoute = true;
    });

    var osmData = OsmData();
    var routes = await osmData.calculateRoundTrip(
        _currentDeviceLocation.latitude,
        _currentDeviceLocation.longitude,
        10000,
        10);

    drawRoute(routes[0]);

    setState(() {
      _isLoadingRoute = false;
      _routes = routes;
      _currentRouteIndex = 0;
    });
  }

  drawRoute(List<Node> route) async {
    mapController.clearLines();

    List<LatLng> routeLatLng =
        route.map((node) => LatLng(node.latitude, node.longitude)).toList();

    routeLatLng = routeLatLng.sublist(0, routeLatLng.length);

    LineOptions optionsPassedRoute =
        LineOptions(geometry: [], lineColor: "Grey", lineWidth: 3.0);
    Line linePassedRoute = await mapController.addLine(optionsPassedRoute);

    LineOptions optionsRoute =
        LineOptions(geometry: routeLatLng, lineColor: "Blue", lineWidth: 4.0);
    Line lineRoute = await mapController.addLine(optionsRoute);

    setState(() {
      _isLoadingRoute = false;
      _route = routeLatLng;
      _lineRoute = lineRoute;
      _linePassedRoute = linePassedRoute;
    });

    //initUpdateRouteTimer();
  }

  drawNextRoute() {
    setState(() {
      _currentRouteIndex = (_currentRouteIndex + 1) % _routes.length;
    });
    drawRoute(_routes[_currentRouteIndex]);
  }

  void initUpdateRouteTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => updateRoute());
  }

  void updateRoute() async {
    List<LatLng> remainingRoute = [];
    List<LatLng> passedRoute = _passedRoute;

    for (int i = 0; i < _route.length; i++) {
      LatLng latLng = _route[i];
      double distanceToCurrentLocation =
          OsmData.getDistance(latLng, _currentDeviceLocation);
      //print("DISTANCE $distanceToCurrentLocation");
      if (distanceToCurrentLocation > 0.0002) {
        remainingRoute.add(latLng);
      } else {
        passedRoute.add(latLng);
        //print("i=" + i.toString() + " latlng = " + latLng.toString() + " length = " + passedRoute.length.toString());
      }
    }

    LineOptions optionsRemainingRoute = LineOptions(geometry: remainingRoute);
    await mapController.updateLine(_lineRoute, optionsRemainingRoute);

    LineOptions optionsPassedRoute = LineOptions(geometry: passedRoute);
    await mapController.updateLine(_linePassedRoute, optionsPassedRoute);

    setState(() {
      _route = remainingRoute;
      _passedRoute = passedRoute;
    });
  }

  void updateRouteManually() async {
    int numberOfNodesToUpdate = _route.length > 5 ? 5 : _route.length;

    List<LatLng> passedRoute = [
      ..._passedRoute,
      ..._route.sublist(0, numberOfNodesToUpdate)
    ];
    List<LatLng> remainingRoute = _route.sublist(numberOfNodesToUpdate - 1);

    LineOptions optionsPassedRoute = LineOptions(geometry: passedRoute);
    await mapController.updateLine(_linePassedRoute, optionsPassedRoute);

    LineOptions optionsRemainingRoute = LineOptions(geometry: remainingRoute);
    await mapController.updateLine(_lineRoute, optionsRemainingRoute);

    setState(() {
      _route = remainingRoute;
      _passedRoute = passedRoute;
    });
  }

  static CameraPosition _getCameraPosition() {
    final latLng = LatLng(52.520008, 13.404954);
    return CameraPosition(
      target: latLng,
      zoom: defaultZoom,
    );
  }

  void _onMapChanged() {
    setState(() {
      _extractMapInfo();
    });
  }

  @override
  void dispose() {
    if (mapController != null) {
      mapController.removeListener(_onMapChanged);
    }
    super.dispose();
  }

  Future<bool> isLocationPermissionGranted() async {
    PermissionStatus permission =
        await LocationPermissions().checkPermissionStatus();
    return permission == PermissionStatus.granted;
  }

  Future<void> requestLocationPermissionIfNotAlreadyGranted() async {
    bool granted = await isLocationPermissionGranted();
    if (!granted) {
      await LocationPermissions().requestPermissions();
      granted = await isLocationPermissionGranted();
      if (granted) forceRebuildMap();
    }
  }

  void cycleTrackingMode(){
    switch (_myLocationTrackingMode) {
      case MyLocationTrackingMode.None:
        {
          setZoom(14);
          setTrackingMode(MyLocationTrackingMode.Tracking);
        }
        break;
      case MyLocationTrackingMode.Tracking:
        {
          setZoom(16);
          setTrackingMode(MyLocationTrackingMode.TrackingCompass);
        }
        break;
      case MyLocationTrackingMode.TrackingCompass:
        {
          setTrackingMode(MyLocationTrackingMode.Tracking);
        }
        break;
      default:
        {
          setTrackingMode(MyLocationTrackingMode.Tracking);
        }
    }
  }

  Icon getTrackingModeIcon(){

    switch (_myLocationTrackingMode) {
      case MyLocationTrackingMode.None:
        {
          return Icon(OMIcons.navigation);
        }
        break;
      case MyLocationTrackingMode.Tracking:
        {
          return Icon(Icons.navigation);
        }
        break;
      case MyLocationTrackingMode.TrackingCompass:
        {
          return Icon(Icons.rotate_90_degrees_ccw);
        }
        break;
      default:
        {
          return Icon(OMIcons.navigation);
        }
    }


  }

  void setTrackingMode(MyLocationTrackingMode mode) async {
    await requestLocationPermissionIfNotAlreadyGranted();
    bool granted = await isLocationPermissionGranted();

    if (granted) {
      setState(() {
        _myLocationTrackingMode = mode;
      });
    }
  }

  //TODO find way to rebuild map?!
  forceRebuildMap() {}

  void setZoom(double zoom) {
    mapController.moveCamera(CameraUpdate.zoomTo(zoom));
  }

  void zoomIn() {
    mapController.moveCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    mapController.moveCamera(CameraUpdate.zoomOut());
  }

  void setLatLng(LatLng latLng) {
    mapController.moveCamera(CameraUpdate.newLatLng(latLng));
  }

  void setMapStyle(String style) {
    setState(() {
      _currentStyle = style;
    });
  }

  void _extractMapInfo() {
    _position = mapController.cameraPosition;
    _isMoving = mapController.isCameraMoving;
  }

  @override
  Widget build(BuildContext context) {
    if (this._tilesLoaded) {
      return Stack(
        children: <Widget>[
          _buildMapBox(context),
          Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: "btn-gps",
                    child: getTrackingModeIcon(),
                    onPressed: () {
                      cycleTrackingMode();
                    },
                  ),
                  FloatingActionButton(
                    heroTag: "btn-maptype",
                    child: Icon(_currentStyle == _styles.keys.first
                        ? Icons.terrain
                        : Icons.satellite),
                    onPressed: () {
                      // TODO for now only switching between klokan and bright
                      setMapStyle(_currentStyle == _styles.keys.first
                          ? _styles.keys.elementAt(1)
                          : _styles.keys.elementAt(0));
                    },
                  ),
                  FloatingActionButton(
                    heroTag: "btn-update",
                    child: Icon(Icons.update),
                    onPressed: () {
                      //updateRoute();
                      drawNextRoute();
                    },
                  ),
                ],
              )),
          if (_isLoadingRoute)
            Dialog(
                child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Center(child: CircularProgressIndicator()),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text("Calculating Route...")),
                    ),
                  ],
                ),
              ),
            ))
        ],
      );
    } else {
      return Center(
        child: new CircularProgressIndicator(),
      );
    }
  }

  MapboxMap _buildMapBox(BuildContext context) {
    return MapboxMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: this._cameraInitialPos,
        trackCameraPosition: true,
        compassEnabled: _compassEnabled,
        cameraTargetBounds: _cameraTargetBounds,
        minMaxZoomPreference: _minMaxZoomPreference,
        styleString: _styles[_currentStyle],
        rotateGesturesEnabled: _rotateGesturesEnabled,
        scrollGesturesEnabled: _scrollGesturesEnabled,
        tiltGesturesEnabled: _tiltGesturesEnabled,
        zoomGesturesEnabled: _zoomGesturesEnabled,
        myLocationEnabled: _myLocationEnabled,
        myLocationTrackingMode: _myLocationTrackingMode,
        onCameraTrackingDismissed: () {
          this.setState(() {
            _myLocationTrackingMode = MyLocationTrackingMode.None;
          });
        });
  }

  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.addListener(_onMapChanged);
    _extractMapInfo();
    setState(() {});
  }
}
