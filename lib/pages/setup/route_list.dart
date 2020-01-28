import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';
import 'package:hiking4nerds/services/routeparams.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class RouteList extends StatefulWidget {
  final RouteParamsCallback onPushRoutePreview;
  final RouteParams routeParams;

  RouteList({@required this.onPushRoutePreview, this.routeParams});

  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  List<RouteListEntry> routeList = [];
  String summary = '';

  bool _routesCalculated = false;

  @override
  void initState() {
    super.initState();
    calculateRoutes();
  }

  Future<void> calculateRoutes() async {
    List<HikingRoute> routes;

    OsmData osm = OsmData();

    try {
      routes = await osm.calculateHikingRoutes(
          widget.routeParams.startingLocation.latitude,
          widget.routeParams.startingLocation.longitude,
          widget.routeParams.distanceKm,
          10,
          widget.routeParams.poiCategories.map((category) => category.id).toList());
    } on NoPOIsFoundException catch (err) {
      print("no poi found exception " + err.toString());
      routes = await osm.calculateHikingRoutes(
        widget.routeParams.startingLocation.latitude,
        widget.routeParams.startingLocation.longitude,
        widget.routeParams.distanceKm,
        10);
    }

    await buildRouteTitles(routes);

    setState(() {
      widget.routeParams.routes = routes;
      print('## ${routes.length} routes found');

      widget.routeParams.routes.forEach((r) => routeList.add(RouteListEntry(
            r.title,
            r.date,
            r.totalLength,
            r.getTotalElevationDifference()
          )));
      switch(widget.routeParams.altitudeType) {
        case AltitudeType.none:
          routeList.shuffle();
          break;
        case AltitudeType.minimal:
          routeList.sort((entryA, entryB) => entryA.altitude.compareTo(entryB.altitude));
          break;
        case AltitudeType.high:
          routeList.sort((entryA, entryB) => entryB.altitude.compareTo(entryA.altitude));
          break;
      }
      this._routesCalculated = true;
    });

  }

  Future<void> buildRouteTitles(List<HikingRoute> routes) async{
    for(int i = 0; i < routes.length; i++){
      String title = await routes[i].buildTitle();
      routes[i].setTitle(title);
    }
  }

  // TODO add localization or remove if not needed
  void summaryText() {
    String text = LocalizationService().getLocalization(english: "Displaying routes for your chosen parameters\n", german: "Routen für die gewählten Parameter werden dargestellt\n");
    text += LocalizationService().getLocalization(english: "Distance:", german: "Distanz:") + '${widget.routeParams.distanceKm}\n';
    text += (widget.routeParams.poiCategories.length > 0) ? 'POIs: \n' : '';
    text += LocalizationService().getLocalization(english: "Altitude:", german: "Höhe:") + '${widget.routeParams.altitudeType}\n';
    print(text);
    summary = text;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if(_routesCalculated) {
      body = Stack(children: <Widget>[
          Text(
            summary,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
            textAlign: TextAlign.left,
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          if(routeList.length > 0)
          ListView.builder(
            itemCount: routeList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
                child: Card(
                  child: ListTile(
                    onTap: () {
                      widget.routeParams.routeIndex = index;
                      widget.onPushRoutePreview(widget.routeParams);
                    },
                    title: Text(routeList[index].title),
                    subtitle: Text(
                            '${LocalizationService().getLocalization(english: "Distance:", german: "Distanz:")}: ${routeList[index].distance.toString()}\t'
                            '${LocalizationService().getLocalization(english: "Altitude", german: "Höhenmeter")}: ${routeList[index].altitude}\n'
                            '${LocalizationService().getLocalization(english: "Date", german: "Datum")}: ${routeList[index].date}'),
                    leading: CircleAvatar(
                        child: Icon(
                      Icons.directions_walk,
                      color: htwGreen,
                    )
                        //backgroundImage: (routeList[index].avatar == null) ? AssetImage('assets/img/h4n-icon2.png') : AssetImage('assets/img/h4n-icon2.png'),
                        ),
                  ),
                ),
              );
            },
          ),
        if(routeList.length == 0)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Text(
                  LocalizationService().getLocalization(english: "No suitable routes could be found. Please consider changing the starting point or some preferences of your route for better results.", german: "Es konnten keine passenden Routen gefunden werden. Bitte versuchen Sie den Startpunkt sowie die Routeneinstellungen anzupassen um eine Route zu finden."),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                Icon(FontAwesomeIcons.mehRollingEyes, size: 52),
              ],
            ),
          ),
        ]);
    }
    else {
      body = Center(
        child: new CircularProgressIndicator(),
      );
    }
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: htwGreen,
          title: Text(LocalizationService().getLocalization(english: "Choose a route to preview", german: "Route für Vorschau wählen")),
          elevation: 0,
        ),
        body: body
      );
  }
}

class RouteListEntry {
  String title; // Route title i.e. Address, city, regio, custom
  String date; // Route date - created
  String distance; // Route length in KM
  double altitude;
  CircleAvatar avatar;

  // RouteListTile({ this.title, this.date, this.distance, this.avatar });

  RouteListEntry(this.title, this.date, double distance, this.altitude) {
    this.distance = formatDistance(distance);
    // this.avatar = avatar;
  }

  String formatDistance(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}
