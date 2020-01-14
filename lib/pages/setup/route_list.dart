import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/routeparams.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';

class RouteList extends StatefulWidget {
  final RouteParamsCallback onPushRoutePreview;
  final RouteParams routeParams;
  final List<HikingRoute> routes;

  RouteList({@required this.onPushRoutePreview, this.routeParams, this.routes});

  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {

  List<RouteListTile> routelist = [
    RouteListTile(title: 'Berlin', date: '16.12.2019', length: 12.4,),
    RouteListTile(title: 'Hamburg', date: '12.12.2019', length: 8.7,),
    RouteListTile(title: 'Harz', date: '18.12.2019', length: 28.8,),
    RouteListTile(title: 'Malerweg', date: '05.08.2019', length: 30.0,),
    RouteListTile(title: 'Berlin', date: '16.12.2019', length: 12.4,),
    RouteListTile(title: 'Hamburg', date: '12.12.2019', length: 8.7,),
    RouteListTile(title: 'Harz', date: '18.12.2019', length: 28.8,),
    RouteListTile(title: 'Malerweg', date: '05.08.2019', length: 30.0,),
    RouteListTile(title: 'Berlin', date: '16.12.2019', length: 12.4,),
    RouteListTile(title: 'Hamburg', date: '12.12.2019', length: 8.7,),
  ];

  void showPrev(index){
    RouteListTile instance = routelist[index];
    // reroute to prev screen
    widget.onPushRoutePreview(widget.routeParams);
  }

  Text summaryText() {
    String text = 'Displaying ${routelist.length} routes for your chosen parameters\n';
    text += 'Distance: ${widget.routeParams.distanceKm}\n';
    text += (widget.routeParams.poiCategories.length > 0) ? 'POIs: \n' : '';
    text += 'Altitude: ${widget.routeParams.altitudeType}\n';
    print(text);
    return Text(text);
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
          summaryText(),
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
                  subtitle: Text('Distance: ${routelist[index].length.toString()}\nDate: ${routelist[index].date}'),
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
  double length; // Route length in KM
  CircleAvatar avatar;

  RouteListTile({ this.title, this.date, this.length, this.avatar });
}