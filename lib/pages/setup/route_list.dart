import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/route_canvas.dart';
import 'package:hiking4nerds/services/elevation_chart.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';
import 'package:hiking4nerds/services/routeparams.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:geocoder/geocoder.dart';

class RouteList extends StatefulWidget {
  final RouteParamsCallback onPushRoutePreview;
  final RouteParams routeParams;

  RouteList({@required this.onPushRoutePreview, this.routeParams});

  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  List<RouteListEntry> _routeList = [];
  bool _routesCalculated = false;
  String _startingLocationAddress = '';

  @override
  void initState() {
    super.initState();
    calculateRoutes();
  }

  Future<void> calculateRoutes() async {
    List<HikingRoute> routes;

    try {
      routes = await OsmData().calculateHikingRoutes(
          widget.routeParams.startingLocation.latitude,
          widget.routeParams.startingLocation.longitude,
          widget.routeParams.distanceKm * 1000.0,
          10,
          widget.routeParams.poiCategories);
    } on NoPOIsFoundException catch (err) {
      print("NoPOIsFoundException: " + err.toString());
      routes = await OsmData().calculateHikingRoutes(
          widget.routeParams.startingLocation.latitude,
          widget.routeParams.startingLocation.longitude,
          widget.routeParams.distanceKm * 1000.0,
          10);
    }

    routes = routes.toList(growable: true);
    routes.removeWhere((elem) => elem == null);
    Address address = await routes[0].findAddress();

    setState(() {
      widget.routeParams.routes = routes;
      widget.routeParams.routes
          .forEach((entry) => _routeList.add(RouteListEntry(context, entry)));
      _startingLocationAddress = '${address.thoroughfare}, ${address.locality}';
      this._routesCalculated = true;
    });
  }

  buildHeader() {

    Table header = Table(
      children: [
        TableRow( children: [
          Text(
              LocalizationService().getLocalization(english: 'Start', german: 'Start'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, color: Colors.grey[600]),
              ),
            Text(
              _startingLocationAddress,
              style: TextStyle(
                fontSize: 16, color: Colors.grey[600]),
            ),
        ]),
        TableRow( children: [
          Text(
              LocalizationService().getLocalization(english: 'Distance', german: 'Distanz'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, color: Colors.grey[600]),
              ),
            Text(
              '${'${widget.routeParams.distanceKm.toInt()} km / ${(widget.routeParams.distanceKm*12).toInt()} min'}',
              style: TextStyle(
                fontSize: 16, color: Colors.grey[600]),
            ),
        ]),
        TableRow( children: [
          Text(
              LocalizationService().getLocalization(english: 'POIs', german: 'POIs'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, color: Colors.grey[600]),
              ),
            Text(
              '${'POI VALUES'}',
              style: TextStyle(
                fontSize: 16, color: Colors.grey[600]),
            ),
        ]),
        TableRow( children: [
          Text(
              LocalizationService().getLocalization(english: 'Altitude differences', german: 'Höhendifferenz'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, color: Colors.grey[600]),
              ),
            Text(
              '${'${AltitudeTypeHelper.asString(widget.routeParams.altitudeType)}'}',
              style: TextStyle(
                fontSize: 16, color: Colors.grey[600]),
            ),
        ]),

    ]);



    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: header,
    );
  }

  generateChips(RouteListEntry entry) {
    List<Widget> chips = List();
    if (entry.pois.isEmpty) {
      entry.pois.add(LocalizationService().getLocalization(
        english: 'No POI found', german: 'Kein POI gefunden'));
    }
    
    entry.pois.forEach((poi) {
      chips.add(new Chip(
        label: Text(poi, style: TextStyle(fontSize: 11, color: Colors.white)),
        backgroundColor: htwGreen,
      ));
    });

    chips.add(Chip(
        backgroundColor: Color(0xFFE1E4F3),
        label: Text(AltitudeTypeHelper.asString(widget.routeParams.altitudeType),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
        )),
    ));

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_routesCalculated) {
      body = Column(
        children: <Widget>[
          buildHeader(),
          Expanded(
            child: SizedBox(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {
                        widget.routeParams.routeIndex = index;
                        widget.onPushRoutePreview(widget.routeParams);
                      },
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 12.0, 12.0, 12.0),
                                  child: Container(
                                    child: _routeList[index].routeCanvas,
                                    decoration: new BoxDecoration(
                                        color: Colors.grey[300],
                                        border: Border.all(color: Colors.grey[600]),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 3.0,
                                          ),
                                        ],
                                        borderRadius: new BorderRadius.all(
                                            const Radius.circular(3.0))),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: Wrap(
                                    spacing: 5,
                                    runSpacing: -10,
                                    children: generateChips(_routeList[index]),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "${_routeList[index].distance} km",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "${_routeList[index].time} min",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.grey[600]),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          Divider(
                            height: 2.0,
                            color: Colors.grey,
                          )
                        ],
                      ));
                },
                itemCount: _routeList.length,
              ),
            ),
          ),
        ],
      );
    } else {
      body = Column(
        children: <Widget>[
          buildHeader(),
          Center(
            child: new CircularProgressIndicator(),
          ),
        ],
      );
    }

    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: htwGreen,
          title: Text(LocalizationService().getLocalization(
              english: 'Choose a route to preview',
              german: 'Route für Vorschau wählen')),
          elevation: 0,
        ),
        body: body,
        );
  }
}

class RouteListEntry {
  String date; // Route date - created
  String distance; // Route length in KM
  String time; // Route time needed in Minutes
  RouteCanvasWidget routeCanvas;
  ElevationChart chart;
  List<String> pois = [];

  // RouteListTile({ this.title, this.date, this.distance, this.avatar });

  RouteListEntry(BuildContext context, HikingRoute route) {
    this.distance = formatDistance(route.totalLength);
    this.time = (route.totalLength * 12).toInt().toString();
    this.routeCanvas = RouteCanvasWidget(
      MediaQuery.of(context).size.width * 0.2,
      MediaQuery.of(context).size.width * 0.2,
      route.path,
      lineColor: Colors.black,
    );
  }

  String formatDistance(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}
