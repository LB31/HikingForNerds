import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/database_helpers.dart';
import 'package:hiking4nerds/services/routeparams.dart';
import 'package:hiking4nerds/services/routing/poi_category.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:hiking4nerds/components/route_canvas.dart';
import 'package:hiking4nerds/services/elevation_chart.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/route.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryEntry> _routes = [];
  bool _routesLoaded = false;
  double _totalDistance = 0;

  @override
  void initState() {
    super.initState();
    loadAllRoutes();
  }

  Future loadAllRoutes() async {
    List<HikingRoute> routes = await DatabaseHelper.instance.queryAllRoutes();
    setState(() {
      _routes.clear();
      if (routes != null)
        routes.forEach((entry) =>  {
          _routes.add(HistoryEntry(context, entry)),
          _totalDistance += entry.totalLength,
        });          
      _routesLoaded = true;
    });
  }

  loadButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(
        child: Text(LocalizationService()
            .getLocalization(english: 'Load routes', german: 'Routen laden')),
        onPressed: () {
          loadAllRoutes();
        },
      ),
    );
  }

  delete(int rid) async {
    DatabaseHelper dbh = DatabaseHelper.instance;
    int id = await dbh.deleteRoute(rid);
  }

  buildHeader() {
    Table header = Table(children: [
      TableRow(children: [
        Text(
          LocalizationService().getLocalization(
              english: 'Saved routes', german: 'Gespeicherte Routen'),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[600]),
        ),
        Text(
          _routes.length.toString(),
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ]),
      TableRow(children: [
        Text(
          LocalizationService().getLocalization(
              english: 'Total route distance',
              german: 'Gesamtlänge der Routen'),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[600]),
        ),
        Text(
          _totalDistance.toString(),
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ])
    ]);

    return Column(children: [
      Padding(padding: const EdgeInsets.all(12.0), child: header),
      Divider(color: htwGrey)
    ]);
  }

  List _generateChips(HistoryEntry entry) {
    List<Widget> chips = List();
    var pois = entry.poiCategories;
    if (pois != null && pois.isNotEmpty) {
      pois.forEach((category) {
        chips.add(new Chip(
          elevation: 1,
          label: Text(
              LocalizationService().getLocalization(
                  english: '${category.nameEng}',
                  german: '${category.nameGer}'),
              style: TextStyle(fontSize: 11, color: Colors.white)),
          backgroundColor: category.color,
        ));
      });
    }

    chips.add(Chip(
      elevation: 1,
      backgroundColor: Color(0xFFE1E4F3),
      label: Text(AltitudeTypeHelper.asString(entry.route.getAltitudeType()),
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
    if (_routesLoaded && _routes.length > 0) {
      body = Column(
        children: <Widget>[
          buildHeader(),
          loadButton(),
          Expanded(
            child: SizedBox(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {},
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
                                    child: _routes[index].routeCanvas,
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
                                    children: _generateChips(_routes[index]),
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
                                        "${_routes[index].distance} km",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "${_routes[index].time} min",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RaisedButton(
                                          child: Text('Delete'),
                                          onPressed: () {
                                            delete(_routes[index].route.dbId);
                                          },
                                        ),
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
                itemCount: _routes.length,
              ),
            ),
          ),
        ],
      );
    } else if (_routesLoaded) {
      Center(
          child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(LocalizationService().getLocalization(
                english: 'No Routes saved yet',
                german: 'Noch keine Routen gespeichert')),
          ),
          loadButton()
        ],
      ));
    } else {
      body = Column(
        children: <Widget>[
          // TODO Remove Button
          loadButton(),
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
        title: Text(LocalizationService()
            .getLocalization(english: 'History', german: 'Verlauf')),
        elevation: 0,
      ),
      body: body,
    );
  }
}

class HistoryEntry {
  String date; // Route date - created
  String distance; // Route length in KM
  String time; // Route time needed in Minutes
  RouteCanvasWidget routeCanvas;
  ElevationChart chart;
  String elevationLevel;
  HikingRoute route;
  Set<PoiCategory> poiCategories;

  HistoryEntry(BuildContext context, HikingRoute route) {
    this.route = route;
    this.date = route.date.toString();
    this.distance = formatDistance(route.totalLength);
    this.time = (route.totalLength * 12).toInt().toString();
    this.routeCanvas = RouteCanvasWidget(
      MediaQuery.of(context).size.width * 0.2,
      MediaQuery.of(context).size.width * 0.2,
      route.path,
      lineColor: Colors.black,
    );

    if (route.pointsOfInterest != null)
      route.pointsOfInterest.forEach((poi) => poiCategories.add(poi.category));

    print(
        'History Entry $date $distance Nodes ${route.path.length} POIs ${poiCategories.length}');
  }

  String formatDistance(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}
