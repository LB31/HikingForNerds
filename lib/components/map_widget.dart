import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hiking4nerds/components/map_buttons.dart';
import 'package:hiking4nerds/services/elevation_chart.dart';
import 'package:hiking4nerds/services/elevation_query.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  final CameraPosition _cameraInitialPos;
  final CameraTargetBounds _cameraTargetBounds;
  static double defaultZoom = 12.0;

  List<LatLng> _passedRoute = [];
  List<LatLng> _route = [];
  Line _lineRoute;
  Line _linePassedRoute;

  //please save the passed route as our DEFINED object ffs!
  HikingRoute _currentRoute;

  LocationData _currentDeviceLocation;
  Timer _timer;

  CameraPosition _position;
  MapboxMapController mapController;
  bool _compassEnabled = true;
  bool _heightChartEnabled = false;
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

  void drawRoute(HikingRoute route) async {
    mapController.clearLines();

    drawRouteStartingPoint(route);
    drawHikingDirection(route);

    List<LatLng> routeLatLng = route.path
        .map((node) => LatLng(node.latitude, node.longitude))
        .toList();

    routeLatLng = routeLatLng.sublist(0, routeLatLng.length);

    LineOptions optionsPassedRoute = LineOptions(
        geometry: [], lineColor: "Grey", lineWidth: 3.0, lineBlur: 2);
    Line linePassedRoute = await mapController.addLine(optionsPassedRoute);

    LineOptions optionsRoute = LineOptions(
        geometry: routeLatLng, lineColor: "Blue", lineWidth: 4.0, lineBlur: 1);
    Line lineRoute = await mapController.addLine(optionsRoute);

    centerCameraOverRoute(route);

    if (route.elevations == null)
      route.elevations = await ElevationQuery.queryElevations(route);

    setState(() {
      _route = routeLatLng;
      _passedRoute = [];
      _lineRoute = lineRoute;
      _linePassedRoute = linePassedRoute;
      _currentRoute = route;
    });

    if (!widget.isStatic) initUpdateRouteTimer();
  }

  void drawRouteStartingPoint(HikingRoute route) {
    mapController.clearCircles();
    LatLng startingPoint = route.path[0];
    CircleOptions optionsStartingPoint = CircleOptions(
        geometry: startingPoint,
        circleColor: "Red",
        circleRadius: 12,
        circleStrokeWidth: 7,
        circleStrokeColor: "Blue",
        circleBlur: 0.25,
        circleOpacity: 1);
    mapController.addCircle(optionsStartingPoint);
  }

  void drawHikingDirection(HikingRoute route) {
    List<LatLng> startingPointPath = route.path.sublist(0, 25);
    List<LatLng> endingPointPath =
        route.path.sublist(route.path.length - 25, route.path.length);

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

  void initUpdateRouteTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => updateRoute());
  }

  void updateRoute() async {
    int currentRouteNodeIndex = 0;
    for (int index = 0; index < _route.length; index++) {
      if (isRouteNodeAtIndexAhead(index)) {
        double distanceToCurrentLocation = OsmData.getDistance(
            _route[index],
            new LatLng(_currentDeviceLocation.latitude,
                _currentDeviceLocation.longitude));
        if (distanceToCurrentLocation < 0.05) {
          currentRouteNodeIndex = index + 1;
        }
      }
    }

    List<LatLng> remainingRoute = _route.sublist(currentRouteNodeIndex);

    LineOptions optionsRemainingRoute = LineOptions(geometry: remainingRoute);
    await mapController.updateLine(_lineRoute, optionsRemainingRoute);

    List<LatLng> passedRoute = [
      ..._passedRoute,
      ..._route.sublist(0, currentRouteNodeIndex + 1)
    ];
    LineOptions optionsPassedRoute = LineOptions(geometry: passedRoute);
    await mapController.updateLine(_linePassedRoute, optionsPassedRoute);

    setState(() {
      _route = remainingRoute;
      _passedRoute = passedRoute;
    });

    if (_route.length <= 1) {
      finishHikingTrip();
    }
  }

  bool isRouteNodeAtIndexAhead(int index) {
    // check if the index is within one of the last 25 nodes and also the route length is less then 50
    if (_route.length > 50 && index > _route.length - 25)
      return false;
    else
      return true;
  }

  //TODO implement nicer/prettier implementation
  void finishHikingTrip() {
    Fluttertoast.showToast(
        msg: "You have finished your Hiking Trip!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.black,
        fontSize: 16.0);

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

  void heightChartMode(){
    this.setState((){
      _heightChartEnabled = !_heightChartEnabled;
    });

    if (_currentRoute != null) {

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
              onHeightChartMode: heightChartMode,
              heightChartDisplayed: _heightChartEnabled,
            ),
          if(_currentRoute != null && _heightChartEnabled)
          _buildElevationChart(context)
        ],
      );
    }
    return Center(
      child: new CircularProgressIndicator(),
    );
  }

  Widget _buildElevationChart(BuildContext context){
    return Container(
      width: 30,
        height: 40,
        child: ElevationChart(
        _currentRoute
        )
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

    requestLocationPermissionIfNotAlreadyGranted().then((result) {
      updateCurrentLocationOnChange();
    });
  }
}
