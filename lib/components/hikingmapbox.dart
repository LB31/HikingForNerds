import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:location/location.dart';
import 'dart:async';

Future<String> _loadJson() async {
  return await rootBundle.loadString('assets/style.json');
}

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final CameraPosition _kInitialPosition;
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
  bool _isMoving = false;
  bool _compassEnabled = true;
  MinMaxZoomPreference _minMaxZoomPreference =
      const MinMaxZoomPreference(6.0, 20.0);
  String _style = "outdoors-v11";
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool _tiltGesturesEnabled = true;
  bool _zoomGesturesEnabled = true;
  bool _myLocationEnabled = true;
  String _customStyle = null;
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.Tracking;

  _MapWidgetState._(
      this._kInitialPosition, this._position, this._cameraTargetBounds);

  @override
  void initState() {
    super.initState();

    requestLocationPermissionIfNotAlreadyGranted().then((result) {
      getCurrentLocation().then((location){
        initRoutes();
      });
      updateCurrentLocationOnChange();
    });
//    _loadJson().then((result) {
//      setState(() {
//        _customStyle = result;
//      });
//    });
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
    var routes =
        await osmData.calculateRoundTrip(_currentDeviceLocation.latitude, _currentDeviceLocation.longitude, 10000, 10);

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

    LineOptions optionsPassedRoute = LineOptions(
        geometry: [], lineColor: "Grey", lineWidth: 3.0);
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


    initUpdateRouteTimer();
  }

  drawNextRoute() {
    setState(() {
      _currentRouteIndex = (_currentRouteIndex + 1) % _routes.length;
    });
    drawRoute(_routes[_currentRouteIndex]);
  }

  void initUpdateRouteTimer(){
    _timer = Timer.periodic(Duration(seconds: 15), (Timer t) => updateRoute());
  }

  void updateRoute() async {

    List<LatLng> remainingRoute = [];
    List<LatLng> passedRoute = _passedRoute;


    for(int i = 0; i < _route.length; i++){
      LatLng latLng = _route[i];
      double distanceToCurrentLocation = OsmData.getDistance(latLng, _currentDeviceLocation);
      //print("DISTANCE $distanceToCurrentLocation");
      if(distanceToCurrentLocation > 0.001){
        remainingRoute.add(latLng);
      }
      else if(i < _route.length - 5 && i > 5) {
        passedRoute.add(latLng);
        print("i=" + i.toString() + " latlng = " + latLng.toString() + " length = " + passedRoute.length.toString());
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

  factory _MapWidgetState() {
    CameraPosition cameraPosition = _getCameraPosition();

    final cityBounds = LatLngBounds(
      southwest: LatLng(52.33826, 13.08835),
      northeast: LatLng(52.67551, 13.76116),
    );

    return _MapWidgetState._(
        cameraPosition, cameraPosition, CameraTargetBounds(cityBounds));
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
      _style = style;
    });
  }

  void _extractMapInfo() {
    _position = mapController.cameraPosition;
    _isMoving = mapController.isCameraMoving;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildMapBox(context),
        Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "btn-zoom-in",
                  child: Icon(Icons.zoom_in),
                  onPressed: () {
                    zoomIn();
                  },
                ),
                FloatingActionButton(
                  heroTag: "btn-zoom-out",
                  child: Icon(Icons.zoom_out),
                  onPressed: () {
                    zoomOut();
                  },
                ),
                FloatingActionButton(
                  heroTag: "btn-navigation",
                  child: Icon(_myLocationTrackingMode ==
                          MyLocationTrackingMode.TrackingCompass
                      ? Icons.navigation
                      : OMIcons.navigation),
                  onPressed: () {
                    setZoom(15.0);
                    setTrackingMode(MyLocationTrackingMode.TrackingCompass);
                  },
                ),
                FloatingActionButton(
                  heroTag: "btn-gps",
                  child: Icon(Icons.gps_fixed),
                  onPressed: () {
                    setTrackingMode(MyLocationTrackingMode.Tracking);
                  },
                ),
                FloatingActionButton(
                  heroTag: "btn-maptype",
                  child: Icon(_style == "outdoors-v11"
                      ? Icons.terrain
                      : Icons.satellite),
                  onPressed: () {
                    if (_style == "satellite-v9")
                      setMapStyle("outdoors-v11");
                    else
                      setMapStyle("satellite-v9");
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
  }

  MapboxMap _buildMapBox(BuildContext context) {
    return MapboxMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: this._kInitialPosition,
        trackCameraPosition: true,
        compassEnabled: _compassEnabled,
        cameraTargetBounds: _cameraTargetBounds,
        minMaxZoomPreference: _minMaxZoomPreference,
        styleString: "mapbox://styles/mapbox/" + _style,
        // _customStyle, for offline use
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
