import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/route_canvas.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';
import 'package:hiking4nerds/services/routeparams.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/poi_category.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiking4nerds/components/loading_text.dart';

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
  String _startingLocationAddress = LocalizationService()
      .getLocalization(english: 'Loading..', german: 'Lädt..');

  @override
  void initState() {
    super.initState();
    widget.routeParams.startingLocation.findAddress().then((address) {
      setState(() {
        _startingLocationAddress = address.addressLine;
      });
    });

    calculateRoutes();
  }

  Future<void> calculateRoutes() async {
    List<HikingRoute> routes = List<HikingRoute>();

    OsmData osm = OsmData();

    try {
      routes = await osm.calculateHikingRoutes(
          widget.routeParams.startingLocation.latitude,
          widget.routeParams.startingLocation.longitude,
          widget.routeParams.distanceKm,
          10,
          widget.routeParams.poiCategories
              .map((category) => category.id)
              .toList());
    } on NoPOIsFoundException catch (err) {
      print("NoPOIsFoundException: " + err.toString());
    }

    if (routes.length == 0) {
      routes = await OsmData().calculateHikingRoutes(
          widget.routeParams.startingLocation.latitude,
          widget.routeParams.startingLocation.longitude,
          widget.routeParams.distanceKm,
          10);
    }

    if (routes.length != 0) {
      routes = routes.toList(growable: true);
      routes.removeWhere((elem) => elem == null);

      setState(() {
        widget.routeParams.routes = routes;

        switch (widget.routeParams.altitudeType) {
          case AltitudeType.none:
            widget.routeParams.routes.shuffle();
            break;
          case AltitudeType.minimal:
            widget.routeParams.routes.sort((a, b) => a
                .getTotalElevationDifference()
                .compareTo(b.getTotalElevationDifference()));
            break;
          case AltitudeType.high:
            widget.routeParams.routes.sort((a, b) => a
                .getTotalElevationDifference()
                .compareTo(b.getTotalElevationDifference()));
            break;
        }

        widget.routeParams.routes
            .forEach((route) => _routeList.add(RouteListEntry(context, route)));

        this._routesCalculated = true;
      });
    } else {
      setState(() {
        this._routesCalculated = true;
      });

      Flushbar(
        messageText: Text(
            LocalizationService().getLocalization(
                english: "An error occured while calculating the routes.",
                german:
                    "Es ist ein Fehler bei der Berechnung der Routen aufgetreten."),
            style: TextStyle(color: Colors.black, fontSize: 16.0)),
        icon: Icon(
          Icons.error,
          size: 28.0,
          color: Colors.black,
        ),
        duration: Duration(seconds: 5),
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 4,
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.red,
      ).show(context);
    }
  }

  buildHeader() {
    Table header = Table(children: [
      TableRow(children: [
        Text(
          LocalizationService()
              .getLocalization(english: 'Start', german: 'Startpunkt'),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[600]),
        ),
        Text(
          _startingLocationAddress,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ]),
      TableRow(children: [
        Text(
          LocalizationService()
              .getLocalization(english: 'Distance', german: 'Distanz'),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[600]),
        ),
        Text(
          '${'${widget.routeParams.distanceKm.toInt()} km / ${(widget.routeParams.distanceKm * 12).toInt()} min'}',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ]),
      TableRow(children: [
        Text(
          LocalizationService()
              .getLocalization(english: 'POIs', german: 'POIs'),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[600]),
        ),
        Text(
          widget.routeParams.poiCategories.isNotEmpty
              ? '${widget.routeParams.poiCategories.map((category) => LocalizationService().getLocalization(english: category.nameEng, german: category.nameGer)).join(", ")}'
              : LocalizationService().getLocalization(
                  english: 'No POI selected', german: 'Kein POI ausgewählt'),
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ]),
      TableRow(children: [
        Text(
          LocalizationService().getLocalization(
              english: 'Altitude differences', german: 'Höhendifferenz'),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[600]),
        ),
        Text(
          '${'${AltitudeTypeHelper.asString(widget.routeParams.altitudeType)}'}',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ]),
    ]);

    return Column(children: [
      Padding(padding: const EdgeInsets.all(12.0), child: header),
      Divider(color: htwGrey)
    ]);
  }

  generateChips(RouteListEntry entry) {
    List<Widget> chips = List();
    if (entry.poiCategories != null && entry.poiCategories.isNotEmpty) {
      entry.poiCategories.forEach((category) {
        if(category != null){
          chips.add(new Chip(
            elevation: 1,
            label: Text(LocalizationService().getLocalization(english: category.nameEng, german: category.nameGer),
                style: TextStyle(fontSize: 11, color: Colors.white)),
            backgroundColor: category.color,
          ));
        }
      });
    }

    chips.add(Chip(
      elevation: 1,
      backgroundColor: Color(0xFFE1E4F3),
      label: Text(AltitudeTypeHelper.asString(entry.altitudeType),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          )),
    ));

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Column(
      children: <Widget>[
        buildHeader(),
        if (_routesCalculated && _routeList.length != 0)
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
                                        border:
                                            Border.all(color: Colors.grey[600]),
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
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Wrap(
                                    spacing: 5,
                                    runSpacing: -10,
                                    children: generateChips(_routeList[index]),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 12, 12, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "${_routeList[index].distance} km",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "${_routeList[index].time} min",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600]),
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
        if (!_routesCalculated)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.13,
                      height: MediaQuery.of(context).size.width * 0.13,
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                "assets/animations/hikergrey.gif",
                              ),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: CircularProgressIndicator(
                                valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.grey[600]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LoadingText(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_routesCalculated && _routeList.length == 0)
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                LocalizationService().getLocalization(
                    english:
                        "No suitable routes could be found. Please consider changing the starting point or some preferences of your route for better results.",
                    german:
                        "Es konnten keine passenden Routen gefunden werden. Bitte versuchen Sie den Startpunkt sowie die Routeneinstellungen anzupassen um eine Route zu finden."),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              Icon(FontAwesomeIcons.mehRollingEyes, size: 52),
            ],
          )),
      ],
    );

    return Scaffold(
      //backgroundColor: Colors.grey[200],
      backgroundColor: Colors.white,
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
  AltitudeType altitudeType;

  // List<PointOfInterest> pois = []; not used rn but could be useful
  Set<PoiCategory> poiCategories = new Set();

  // RouteListTile({ this.title, this.date, this.distance, this.avatar });

  RouteListEntry(BuildContext context, HikingRoute route) {
    this.distance = formatDistance(route.totalLength);
    this.time = (route.totalLength * 12).toInt().toString();
    this.altitudeType = route.getAltitudeType();

    this.routeCanvas = RouteCanvasWidget(
      MediaQuery.of(context).size.width * 0.2,
      MediaQuery.of(context).size.width * 0.2,
      route.path,
      lineColor: Colors.black,
    );
  
    if (route.pointsOfInterest != null)
      route.pointsOfInterest.forEach((poi) => poiCategories.add(poi.category));
  }

  String formatDistance(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}
