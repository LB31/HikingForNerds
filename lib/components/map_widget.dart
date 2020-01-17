import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/map_buttons.dart';
import 'package:hiking4nerds/services/sharing/geojson_data_handler.dart';
import 'package:hiking4nerds/services/sharing/gpx_data_handler.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart';
import 'dart:math';

class MapWidget extends StatefulWidget {
  final bool isStatic;

  MapWidget({Key key, @required this.isStatic}) : super(key: key);

  @override
  MapWidgetState createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  static const double defaultZoom = 12.0;
  final CameraPosition _cameraInitialPos;
  final CameraTargetBounds _cameraTargetBounds;

  static const platform =
      const MethodChannel('app.channel.hikingfornerds.data');
  HikingRoute sharedRoute;

  int _currentRouteIndex = 0;
  List<LatLng> _route = [];
  List<LatLng> _passedRoute = [];
  List<LatLng> _remainingRoute = [];
  Line _lineRemainingRoute;
  Line _linePassedRoute;

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

  MapWidgetState._(
      this._cameraInitialPos, this._position, this._cameraTargetBounds);

  factory MapWidgetState() {
    CameraPosition cameraPosition = _getCameraPosition();

    // get bounds for areas at https://boundingbox.klokantech.com/
    // bounds germany
    final countryBounds = LatLngBounds(
      southwest: LatLng(47.27, 5.87),
      northeast: LatLng(55.1, 15.04),
    );

    return MapWidgetState._(
        cameraPosition, cameraPosition, CameraTargetBounds(countryBounds));
  }

  @override
  initState() {
    super.initState();
    _loadOfflineTiles();
    _getIntentData();
  }

  Future<void> _getIntentData() async {
    var data = await _getSharedData();
    if (data == null) return;
    setState(() {
      sharedRoute = data;
    });
  }

  _getSharedData() async {
    String dataPath = await platform.invokeMethod("getSharedData");
    if (dataPath.isEmpty) return null;
    var data;
    if (dataPath.endsWith(".geojson"))
      data = new GeojsonDataHandler().parseRouteFromPath(dataPath);
    else if (dataPath.endsWith(".gpx"))
      data = new GpxDataHandler().parseRouteFromString(dataPath);
    return data;
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
    return currentLocation;
  }

  void drawRoute(HikingRoute route) async {
    mapController.clearLines();

    drawRouteStartingPoint(route);
    drawHikingDirection(route);

    List<LatLng> routeLatLng = route.path
        .map((node) => LatLng(node.latitude, node.longitude))
        .toList();

    routeLatLng = routeLatLng.sublist(0, routeLatLng.length);

    LineOptions optionsPassedRoute = LineOptions(
        geometry: [],
        lineColor: "Grey",
        lineWidth: 3.0,
        lineBlur: 2,
        lineOpacity: 0.5);
    Line linePassedRoute = await mapController.addLine(optionsPassedRoute);

    LineOptions optionsRoute = LineOptions(
        geometry: routeLatLng,
        lineColor: "Blue",
        lineWidth: 4.0,
        lineBlur: 1,
        lineOpacity: 0.5);

    Line lineRoute = await mapController.addLine(optionsRoute);

    centerCameraOverRoute(route);

    setState(() {
      _route = routeLatLng;
      _remainingRoute = routeLatLng;
      _passedRoute = [];
      _lineRemainingRoute = lineRoute;
      _linePassedRoute = linePassedRoute;
      _currentRouteIndex = 0;
    });

    if (!widget.isStatic){
      startRoute();
    }
  }

  void drawRouteStartingPoint(HikingRoute route) {
    mapController.clearCircles();
    LatLng startingPoint = route.path[0];
    CircleOptions optionsStartingPoint = CircleOptions(
        geometry: startingPoint,
        circleColor: "Red",
        circleRadius: 11,
        circleStrokeWidth: 7,
        circleStrokeColor: "Blue",
        circleBlur: 0.25,
        circleOpacity: 1);
    mapController.addCircle(optionsStartingPoint);
  }

  void drawHikingDirection(HikingRoute route) {
    List<LatLng> startingPointPath = new List<LatLng>();
    List<LatLng> endingPointPath = new List<LatLng>();
    // use a twentieth of the routes total length for start and end route
    double routeEndingLength = route.totalLength * 0.05;

    double startPathLength = 0, endPathLength = 0;
    int i = 0;
    while (startingPointPath.length == 0 || endingPointPath.length == 0) {
      if (startingPointPath.length == 0) {
        if (startPathLength > routeEndingLength) {
          startingPointPath = route.path.sublist(0, i + 1);
        } else {
          startPathLength +=
              OsmData.getDistance(route.path[i], route.path[i + 1]);
        }
      }
      if (endingPointPath.length == 0) {
        if (endPathLength > routeEndingLength) {
          endingPointPath = route.path.sublist(route.path.length - i, route.path.length);
        } else {
          endPathLength += OsmData.getDistance(
              route.path[route.path.length - i - 1],
              route.path[route.path.length - i - 2]);
        }
      }
      i++;
    }

    LineOptions optionsHikingDirectionStart = LineOptions(
        geometry: startingPointPath,
        lineColor: "Green",
        lineWidth: 10.0,
        lineBlur: 2,
        lineOpacity: 0.5);
    LineOptions optionsHikingDirectionEnd = LineOptions(
        geometry: endingPointPath,
        lineColor: "Red",
        lineWidth: 10.0,
        lineBlur: 2,
        lineOpacity: 0.5);

    mapController.addLine(optionsHikingDirectionStart);
    mapController.addLine(optionsHikingDirectionEnd);
  }

  void centerCameraOverRoute(HikingRoute route) {
    double averageLat = 0;
    double averageLong = 0;

    for (int i = 0; i < route.path.length; i++) {
      averageLat += route.path[i].latitude;
      averageLong += route.path[i].longitude;
    }
    averageLat /= route.path.length;
    averageLong /= route.path.length;
    setLatLng(LatLng(averageLat, averageLong));
    double zoom = 14.5 - (pow(route.totalLength, 0.4));
    setZoom(zoom);
  }

  startRoute(){
    setZoom(16);
    setTrackingMode(MyLocationTrackingMode.TrackingCompass);
    initUpdateRouteTimer();

    Flushbar(
      messageText: Text("Your hiking trip has started!", // TODO add localization
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0)
      ),
      icon: Icon(
        Icons.check,
        size: 28.0,
        color: Colors.black,
      ),
      duration: Duration(seconds: 5),
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: EdgeInsets.all(8),
      borderRadius: 4,
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: htwGreen,
    ).show(context);
  }

  void initUpdateRouteTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => updateRoute());
  }

  bool isRouteNodeAtIndexAhead(int index) {
    // check if the index is within one of the last 25 nodes and also the route length is less then 50
    if (_route.length > 50 && index > _route.length - 25)
      return false;
    else
      return true;
  }

  void updateRoute() async {

    LocationData userLocation = await getCurrentLocation();
    LatLng userLatLng = LatLng(userLocation.latitude, userLocation.longitude);
    int currentRouteIndex = _currentRouteIndex;

    int finalRouteNodesOffset = _remainingRoute.length < _route.length - 25 ? 0 : 25;


    for (int index = currentRouteIndex; index < _route.length - finalRouteNodesOffset; index++) {

      double distanceToCurrentLocation = OsmData.getDistance(
          _route[index], userLatLng);

      if (distanceToCurrentLocation < 0.1) {
        print(index.toString() + " / " + _route.length.toString() + " close");
        currentRouteIndex = index;
      }
    }

    setState(() {
      _remainingRoute = _route.sublist(currentRouteIndex);
      _passedRoute = _route.sublist(0, currentRouteIndex + 1);
      _currentRouteIndex = currentRouteIndex;
    });

    LineOptions optionsRemainingRoute = LineOptions(geometry: _remainingRoute);
    await mapController.updateLine(_lineRemainingRoute, optionsRemainingRoute);
    LineOptions optionsPassedRoute = LineOptions(geometry: _passedRoute);
    await mapController.updateLine(_linePassedRoute, optionsPassedRoute);

    if (_remainingRoute.length <= 1) {
      finishHikingTrip();
    }

  }

  //TODO implement nicer/prettier implementation
  void finishHikingTrip() {
    Flushbar(
      messageText: Text("You have finished your hiking trip", // TODO add localization
          style: TextStyle(
              color: Colors.black,
              fontSize: 16.0)
      ),
      icon: Icon(
        Icons.thumb_up,
        size: 28.0,
        color: Colors.black,
      ),
      duration: Duration(seconds: 5),
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: EdgeInsets.all(8),
      borderRadius: 4,
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: htwGreen,
    ).show(context);

    setState(() {
      _passedRoute = [];
      _route = [];
    });

    mapController.clearLines();
    mapController.clearCircles();
    _timer.cancel();
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

  void cycleTrackingMode() {
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
  void forceRebuildMap() {}

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
          if (!widget.isStatic)
            MapButtons(
              currentTrackingMode: _myLocationTrackingMode,
              styles: _styles,
              currentStyle: _currentStyle,
              onCycleTrackingMode: cycleTrackingMode,
              setMapStyle: setMapStyle,
            ),
        ],
      );
    }
    return Center(
      child: new CircularProgressIndicator(),
    );
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
    if (sharedRoute != null) drawRoute(sharedRoute);
  }
}
