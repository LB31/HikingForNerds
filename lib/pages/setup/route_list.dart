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

  List<RouteListTile> routelist = [
    // RouteListTile(title: 'Berlin', date: '16.12.2019', distance: 12.4,),
  ];
  String summary = '';

    @override
  void initState() {
    super.initState();
    calculateRoutes();
  }

  Future<void> calculateRoutes() async {
    List<HikingRoute> routes = await OsmData().calculateHikingRoutes(
        widget.routeParams.startingLocation.latitude,
        widget.routeParams.startingLocation.longitude,
        widget.routeParams.distanceKm * 1000.0,
        10);

    /*
    try {
      routes = await OsmData().calculateHikingRoutes(
          widget.routeParams.startingLocation.latitude,
          widget.routeParams.startingLocation.longitude,
          widget.routeParams.distanceKm * 1000.0,
          10,
          widget.routeParams.poiCategories[0]);
    } catch (err) {
      if (err == NoPOIsFoundException) {
        print("no poi found exception");

      }
    }
    */

    setState(() {
      widget.routeParams.routes = routes;
      print('## ${routes.length} routes found');
      widget.routeParams.routes.forEach((r) => routelist.add(RouteListTile(r.title, r.date, r.totalLength,)));      
    });
  }

  void showPrev(index){
    // reroute to prev screen
    widget.routeParams.routeIndex = index;
    widget.onPushRoutePreview(widget.routeParams);
  }

  void summaryText() {
    String text = 'Displaying routes for your chosen parameters\n';
    text += 'Distance: ${widget.routeParams.distanceKm}\n';
    text += (widget.routeParams.poiCategories.length > 0) ? 'POIs: \n' : '';
    text += 'Altitude: ${widget.routeParams.altitudeType}\n';
    print(text);
    summary = text;
  }

  @override
  Widget build(BuildContext context) {
    print('build func running');
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: htwGreen,
        title: Text('Choose a route to preview'),
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          Text(
            summary,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600]),
            textAlign: TextAlign.left,
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          ListView.builder(
          itemCount: routelist.length,
          itemBuilder: (context, index){
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
              child: Card(
                child: ListTile(
                  onTap: () {
                    showPrev(index);
                  },
                  title: Text(routelist[index].title),
                  subtitle: Text('Distance: ${routelist[index].distance.toString()}\nDate: ${routelist[index].date}'),
                  leading: CircleAvatar(
                    child: Icon(Icons.directions_walk, color: htwGreen,)
                    //backgroundImage: (routelist[index].avatar == null) ? AssetImage('assets/img/h4n-icon2.png') : AssetImage('assets/img/h4n-icon2.png'),
                  ),
                ),
              ),
            );
          },
        ),
        ])
    );
  }
}

class RouteListTile {

  String title; // Route title i.e. Address, city, regio, custom
  String date; // Route date - created
  String distance; // Route length in KM
  CircleAvatar avatar;

  // RouteListTile({ this.title, this.date, this.distance, this.avatar });

  RouteListTile(String title, String date, double distance) {
    this.title = title;
    this.date = date;
    this.distance = format(distance);
    // this.avatar = avatar;
  }

  String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}