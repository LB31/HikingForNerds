import 'dart:async';
import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/map_buttons.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/routing/geo_utilities.dart';
import 'package:hiking4nerds/services/sharing/geojson_data_handler.dart';
import 'package:hiking4nerds/services/sharing/gpx_data_handler.dart';
import 'package:hiking4nerds/services/elevation_query.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:hiking4nerds/services/pointofinterest.dart';

class MapWidget extends StatefulWidget {
  final bool isStatic;
  final VoidCallback onElevationChartToggle;

  MapWidget({Key key, @required this.isStatic, this.onElevationChartToggle}) : super(key: key);

  @override
  MapWidgetState createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  static const double defaultZoom = 12.0;
  static const double displayPoiSymbolZoom = 14.0;
  final CameraPosition _cameraInitialPos;
  final CameraTargetBounds _cameraTargetBounds;

  static bool _isCurrentlyGranting = false;
  static bool lockMarkerTransaction = false;

  static const platform =
      const MethodChannel('app.channel.hikingfornerds.data');
  HikingRoute sharedRoute;

  HikingRoute _hikingRoute;
  int _currentRouteIndex = 0;
  List<LatLng> _route = [];
  List<LatLng> _passedRoute = [];
  List<LatLng> _remainingRoute = [];
  Line _lineRemainingRoute;
  Line _linePassedRoute;
  Line _lineStartRoute;
  LatLng _lastUserLocation;

  Timer _timer;

  double _lastZoom = 12;

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
  Symbol selectedElevationSymbol;
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
    if (Platform.isAndroid)
      _getIntentData();
    _requestPermissions();
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

  void _requestPermissions() async {
    await requestLocationPermissionIfNotAlreadyGranted();
  }

  Future<void> _loadOfflineTiles() async {
    try {
      _styles["klokan-tech"] = "https://h4nsolo.f4.htw-berlin.de/styles/klokantech-basic/style.json";
      _styles["bright-osm"] = "https://h4nsolo.f4.htw-berlin.de/styles/osm-bright/style.json";
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

  void clearMap() {
    mapController.clearLines();
    mapController.clearCircles();
    mapController.clearSymbols();
  }

  void drawRoute(HikingRoute route, [bool center = true]) async {
    clearMap();
    drawRouteStartingPoint(route);
    drawPois(route, 12);
    int index = calculateLastStartingPathNode(route);
    assert(index != -1, "Error last starting node not found!");

    LineOptions optionsPassedRoute = LineOptions(
        geometry: [route.path[0]],
        lineColor: "#AAAAAA",
        lineWidth: 4.0,
        lineBlur: 2,
        lineOpacity: 0.5);
    Line linePassedRoute = await mapController.addLine(optionsPassedRoute);

    LineOptions optionsRoute = LineOptions(
        geometry: route.path.sublist(index - 1),
        lineColor: "#0000FF",
        lineWidth: 4.0,
        lineBlur: 1,
        lineOpacity: 0.5);

    Line lineRoute = await mapController.addLine(optionsRoute);

    LineOptions optionsStartRoute = LineOptions(
        geometry: route.path.sublist(0, index),
        lineColor: "#009933",
        lineWidth: 4.0,
        lineBlur: 1,
        lineOpacity: 0.5);

    Line lineStartRoute = await mapController.addLine(optionsStartRoute);

    if (center) centerCameraOverRoute(route);

    if (route.elevations == null)
      route.elevations = await ElevationQuery.queryElevations(route);

    setState(() {
      _hikingRoute = route;
      _route = route.path;
      _remainingRoute = route.path;
      _passedRoute = [];
      _lineRemainingRoute = lineRoute;
      _lineStartRoute = lineStartRoute;
      _linePassedRoute = linePassedRoute;
      _currentRouteIndex = 0;
      _lastUserLocation = null;
    });

    if (!widget.isStatic) {
      startRoute();
    }
  }

  Future<void> drawRouteStartingPoint(HikingRoute route) async {
    LatLng startingPoint = route.path[0];
    CircleOptions optionsStartingPoint = CircleOptions(
        geometry: startingPoint,
        circleColor: "#0000FF",
        circleRadius: 16,
        circleBlur: 0.25,
        circleOpacity: 0.5);
    await mapController.addCircle(optionsStartingPoint);
  }

  int calculateLastStartingPathNode(HikingRoute route) {
    List<LatLng> startingPointPath = new List<LatLng>();
    // use a twentieth of the routes total length for start and end route
    double routeEndingLength = route.totalLength * 0.05;

    double startPathLength = 0;
    int i = 0;
    while (startingPointPath.length == 0) {
      if (startPathLength > routeEndingLength) {
        return i + 1;
      } else {
        startPathLength +=
            getDistance(route.path[i], route.path[i + 1]);
      }
      i++;
    }

    return -1;
  }

  void drawPois(HikingRoute route, double zoom) async {
    List<PointOfInterest> pois = route.pointsOfInterest;
    if (pois != null) {
      pois.forEach((poi) async {
        if (zoom < displayPoiSymbolZoom) {
          await mapController.clearSymbols();
          CircleOptions poiOptions = CircleOptions(
              geometry: LatLng(poi.latitude, poi.longitude),
              circleColor: poi.category.colorAsHex(),
              circleRadius: 3,
              circleBlur: 0.25,
              circleOpacity: 0.8);
          await mapController.addCircle(poiOptions);
        } else {
          await mapController.clearCircles();
          await drawRouteStartingPoint(_hikingRoute);
          SymbolOptions poiOptions = SymbolOptions(
              iconImage: poi.category.symbolPath,
              geometry: LatLng(poi.latitude, poi.longitude),
              iconSize: 1,
          );
          await mapController.addSymbol(poiOptions);
        }
      });
    }

    setState(() {});
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
    double zoom = 14.5 - (pow(route.totalLength, 0.4));

    setLatLng(LatLng(averageLat, averageLong));
    setZoom(zoom);
  }

  startRoute() {
    setZoom(16);
    setLatLng(_hikingRoute.path[0]);
    initUpdateRouteTimer();

    Flushbar(
      messageText: Text(
          LocalizationService().getLocalization(
              english: "Your hiking trip has started!",
              german: "Ihre Wanderung hat begonnen!"),
          style: TextStyle(color: Colors.black, fontSize: 16.0)),
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

  bool userLocationChanged(LatLng currentLocation) {
    if (_lastUserLocation == null) return true;

    double distance = getDistance(currentLocation, _lastUserLocation);
    return distance > 0.001;
  }

  void updateRoute() async {
    LocationData userLocation = await getCurrentLocation();
    LatLng userLatLng = LatLng(userLocation.latitude, userLocation.longitude);

    if (userLocationChanged(userLatLng)) {
      int currentRouteIndex = _currentRouteIndex;

      //The final 25 nodes of the route can not be "visited" until at least the first 25 nodes have been "visited".
      int finalRouteNodesThreshold =
          _remainingRoute.length < _route.length - 25 ? 0 : 25;

      for (int i = currentRouteIndex; i < _route.length - finalRouteNodesThreshold; i++) {
        double distanceToCurrentLocation = getDistance(_route[i], userLatLng);
        if (distanceToCurrentLocation < 0.1) {
          currentRouteIndex = i;
          break;
        }
      }

      setState(() {
        _remainingRoute = _route.sublist(currentRouteIndex);
        _passedRoute = _route.sublist(0, currentRouteIndex + 1);
        _currentRouteIndex = currentRouteIndex;
        _lastUserLocation = userLatLng;
      });

      LineOptions optionsRemainingRoute = LineOptions(geometry: _remainingRoute);
      await mapController.updateLine(_lineRemainingRoute, optionsRemainingRoute);
      LineOptions optionsPassedRoute = LineOptions(geometry: _passedRoute);
      await mapController.updateLine(_linePassedRoute, optionsPassedRoute);
    }

    if (_remainingRoute.length <= 1) {
      finishHikingTrip();
    }
  }

  //TODO implement nicer/prettier implementation
  void finishHikingTrip() {
    Flushbar(
      messageText: Text(
          LocalizationService().getLocalization(
              english: "You have finished your hiking trip!",
              german: "Sie haben Ihre Wanderung abgeschlossen!"),
          style: TextStyle(color: Colors.black, fontSize: 16.0)),
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

    updateTotalHikingDistance();
  }

  updateTotalHikingDistance() {
    SharedPreferences.getInstance().then((prefs) {
      double totalHikingDistance = prefs.getDouble("totalHikingDistance") ?? 0;
      totalHikingDistance += _hikingRoute.totalLength;
      prefs.setDouble("totalHikingDistance", totalHikingDistance);
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
    double currentZoom = mapController.cameraPosition.zoom;
    if (currentZoom > displayPoiSymbolZoom && _lastZoom <= displayPoiSymbolZoom)
      drawPois(_hikingRoute, currentZoom);
    else if (currentZoom < displayPoiSymbolZoom &&
        _lastZoom >= displayPoiSymbolZoom) drawPois(_hikingRoute, currentZoom);

    setState(() {
      _extractMapInfo();
      _lastZoom = currentZoom;
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
    if (!granted && !_isCurrentlyGranting) {
      _isCurrentlyGranting = true;
      await LocationPermissions().requestPermissions();
      _isCurrentlyGranting = false;
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
              onElevationChartToggle: widget.onElevationChartToggle,
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

  Future<void> markElevation(int index) async {
    if (lockMarkerTransaction) return;
    lockMarkerTransaction = true;
    LatLng latLngPosition = _route[index];
    SymbolOptions optionsElevationPoint = SymbolOptions(
      geometry: latLngPosition,
      iconImage: "assets/img/symbols/location_pin.png",
      iconOffset: Offset(0, -10),
      );
    if (selectedElevationSymbol == null)
      selectedElevationSymbol = await mapController.addSymbol(optionsElevationPoint);
    else
      await mapController.updateSymbol(selectedElevationSymbol, optionsElevationPoint);

    lockMarkerTransaction = false;
  }

  void removeSelectedElevation(){
    if (selectedElevationSymbol != null) {
      mapController.removeSymbol(selectedElevationSymbol);
      selectedElevationSymbol = null;
    }
  }
}
