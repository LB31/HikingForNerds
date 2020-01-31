import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/shareroute.dart';
import 'package:hiking4nerds/pages/setup/route_preview.dart';
import 'package:hiking4nerds/services/routeparams.dart';
import 'package:hiking4nerds/services/routing/poi_category.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:hiking4nerds/components/route_canvas.dart';
import 'package:hiking4nerds/services/elevation_chart.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/route.dart';

class HistoryPage extends StatefulWidget {
  static List<HistoryEntry> entries = new List<HistoryEntry>();
  final SwitchToMapCallback onSwitchToMap;

  HistoryPage({Key key, @required this.onSwitchToMap}) : super(key: key);

  @override
  HistoryPageState createState() => HistoryPageState();

  static void addRouteIfNew(HikingRoute route) {
    for (HistoryEntry entry in entries) {
        if (ListEquality().equals(entry.route.path, route.path))
          return;
    }
    entries.add(new HistoryEntry(route));
  }
}

class HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
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
          HistoryPage.entries.length.toString(),
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ]),
      TableRow(children: [
        Text(
          LocalizationService().getLocalization(
              english: 'Total route(s) distance',
              german: 'Gesamtlänge der Routen'),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[600]),
        ),
        Text(
          formatDistance(HistoryPage.entries
                  .map((l) => l.route.totalLength)
                  .fold(0, (a, b) => a + b)) +
              ' km',
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
      label: Text(AltitudeTypeHelper.asString(entry.altitudeType),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          )),
    ));

    return chips;
  }

  void updateState() {
    setState(() {});
    for (HistoryEntry entry in HistoryPage.entries) {
      if (entry.address == "Loading") continue;
      entry.route.path.first.findAddress().then((result) {
        setState(() {
          entry.address = result.addressLine;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (HistoryPage.entries.length > 0) {
      body = Column(
        children: <Widget>[
          buildHeader(),
          Expanded(
            child: SizedBox(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {
                        HikingRoute route = HistoryPage.entries[index].route;
                        widget.onSwitchToMap(route);
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
                                    child: RouteCanvasWidget(
                                      MediaQuery.of(context).size.width * 0.2,
                                      MediaQuery.of(context).size.width * 0.2,
                                      HistoryPage.entries[index].route.path,
                                      lineColor: Colors.black,
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        border:
                                            Border.all(color: Colors.grey[600]),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 3.0,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.all(
                                            const Radius.circular(3.0))),
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                          '${HistoryPage.entries[index].address}'),
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: Wrap(
                                        spacing: 5,
                                        runSpacing: -10,
                                        children: _generateChips(
                                            HistoryPage.entries[index]),
                                      ),
                                    ),
                                  ],
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
                                        "${HistoryPage.entries[index].distance} km",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "${HistoryPage.entries[index].time} min",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: RawMaterialButton(
                                          onPressed: () {
                                            setState(() {
                                              HistoryPage.entries
                                                  .removeAt(index);
                                            });
                                          },
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: Colors.black,
                                            size: 20.0,
                                          ),
                                          shape: CircleBorder(),
                                          elevation: 2.0,
                                          fillColor: htwGreen,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: RawMaterialButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ShareRoute(
                                                        route: HistoryPage
                                                            .entries[index]
                                                            .route));
                                          },
                                          child: Icon(
                                            Icons.share,
                                            color: Colors.black,
                                            size: 20.0,
                                          ),
                                          shape: CircleBorder(),
                                          elevation: 2.0,
                                          fillColor: htwGreen,
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
                itemCount: HistoryPage.entries.length,
              ),
            ),
          ),
        ],
      );
    } else {
      body = Center(
          child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(LocalizationService().getLocalization(
                english: 'No Routes saved yet',
                german: 'Noch keine Routen gespeichert')),
          ),
        ],
      ));
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
  ElevationChart chart;
  String elevationLevel;
  HikingRoute route;
  Set<PoiCategory> poiCategories;
  String address = "Loading..";
  AltitudeType altitudeType;

  HistoryEntry(HikingRoute route) {
    this.route = route;
    this.date = route.date.toString();
    this.distance = formatDistance(route.totalLength);
    this.time = (route.totalLength * 12).toInt().toString();
    route.path.first.findAddress().then((result) {
      this.address = result.addressLine;
    });
    this.altitudeType = AltitudeTypeHelper.differenceToType(
        route.getTotalElevationDifference(), route.path.length);
    poiCategories = Set();
    if (route.pointsOfInterest != null)
      route.pointsOfInterest.forEach((poi) => poiCategories.add(poi.category));

    print(
        'History Entry $date $distance Nodes ${route.path.length} POIs ${poiCategories.length}');
  }
}

String formatDistance(double n) {
  return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
}
