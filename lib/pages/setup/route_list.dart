import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';
import 'package:hiking4nerds/services/routeparams.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';

class RouteList extends StatefulWidget {
  final RouteParamsCallback onPushRoutePreview;
  final RouteParams routeParams;

  RouteList({@required this.onPushRoutePreview, this.routeParams});

  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  List<RouteListEntry> routeList = [];

  @override
  void initState() {
    super.initState();
    // todo implement loading bar
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
        print("no poi found exception " + err.toString());
    } finally {
      routes = await OsmData().calculateHikingRoutes(
          widget.routeParams.startingLocation.latitude,
          widget.routeParams.startingLocation.longitude,
          widget.routeParams.distanceKm * 1000.0,
          10);
    }
    setState(() {
      widget.routeParams.routes = routes;
      widget.routeParams.routes.forEach((r) => routeList.add(RouteListEntry(
            r.title,
            r.date,
            r.totalLength,
          )));
    });
  }

  // TODO add localization or remove if not needed
  headerText() {

    String paramTitles = 'Distance: ';
    if(widget.routeParams.poiCategories.length > 0) {
      paramTitles += '\nPOIs: ';
      for(var i = 1; i < widget.routeParams.poiCategories.length; i++) paramTitles += '\n';
      // widget.routeParams.poiCategories.forEach((p) => paramTitles += '\n');
    }
    paramTitles += '\nAltitude differences: ';

    String params = '${widget.routeParams.distanceKm.toInt()} KM / ${(widget.routeParams.distanceKm*12).toInt()} MIN';
    if(widget.routeParams.poiCategories.length > 0) {
      widget.routeParams.poiCategories.forEach((p) => params += '\n$p ');
    }
    params += '\n${AltitudeTypeHelper.asString(widget.routeParams.altitudeType)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child:
              Text(paramTitles,
                style: TextStyle(
                // fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
                textAlign: TextAlign.left,
              ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child:
              Text(params,
                style: TextStyle(
                // fontSize: 14,
                color: Colors.grey[600]),
                textAlign: TextAlign.left,
              ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: htwGreen,
          title: Text('Choose a route to preview'), // TODO add localization
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 4)),
            headerText(),
            Padding(padding: EdgeInsets.only(top: 4)),
            Expanded(
                          child: ListView.builder(
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
                            'Distance: ${routeList[index].distance} KM / ${routeList[index].time} MIN\n'),// TODO localization
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
            ),
        ]));
  }
}

class RouteListEntry {
  String title; // Route title i.e. Address, city, regio, custom
  String date; // Route date - created
  String distance; // Route length in KM
  String time; // Route time needed in Minutes
  CircleAvatar avatar;

  // RouteListTile({ this.title, this.date, this.distance, this.avatar });

  RouteListEntry(String title, String date, double distance) {
    this.title = title;
    this.date = date;
    this.distance = formatDistance(distance);
    this.time = (distance * 12).toInt().toString();
    // this.avatar = avatar;
  }

  String formatDistance(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}
