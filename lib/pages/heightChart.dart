import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:hiking4nerds/osmdata.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:hiking4nerds/components/hikingmap.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

class HeightChart extends StatelessWidget {
  List<double> foundHeights = new List();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lots of Items'),
        backgroundColor: htwGreen,
      ),
      body: buildList(),
    );
    // print("bah");
    // var points = HikingMapState.routePoints;
    // if (foundHeights.length == 0) getRouteElevations(points, context);
    // return draw();
  }

  Widget buildList() {
    return FutureBuilder(
      future:
          getRouteElevations(HikingMapState.routePoints), // <--- get a future
      builder: (BuildContext context, snapshot) {
        // <--- build the things.
        if(snapshot.connectionState == ConnectionState.done) print("data");
        else print("no data");
        return Container(
          width: 300.0,
          height: 100.0,
          child: new Sparkline(
            data: snapshot.connectionState == ConnectionState.done ?
            this.foundHeights : [0],
            pointsMode: PointsMode.all,
            pointSize: 8.0,
            pointColor: Colors.amber,
            fillMode: FillMode.below,
            fillColor: Colors.red[200],
          ),
        );
      },
    );
  }


  Future<dynamic> getRouteElevations(List<Node> points) async {
    
    print("BAM");
    var url =
        "https://h4nsolo.f4.htw-berlin.de/elevation/api/v1/lookup?locations=";

    for (var i = 0; i < 50; i++) {
      url +=
          points[i].latitude.toString() + "," + points[i].longitude.toString();
      if (i != 50 - 1) url += "|";
    }
    print("gsegfsdfsdfddf");
    var response = await http.get(url);
    var parsedData = JSON.jsonDecode(response.body);
    List<double> allHeights = new List();
    for (var i = 0; i < 50; i++) {
      allHeights.add(parsedData["results"][i]["elevation"].toDouble());
      print(parsedData["results"][i]["elevation"].toDouble());
    }


    print("GFDSG");

    print("reads");
    this.foundHeights = allHeights;

    return null;
  }

  Widget draw() {
    if (foundHeights.length == 0) return new Container();
    var data = this.foundHeights;
    print(data);
    return Scaffold(
      appBar: AppBar(
        title: Text('Height Chart'),
        backgroundColor: htwGreen,
      ),
      body: new Center(
        child: new Container(
          width: 300.0,
          height: 100.0,
          child: new Sparkline(
            data: data,
            pointsMode: PointsMode.all,
            pointSize: 8.0,
            pointColor: Colors.amber,
            fillMode: FillMode.below,
            fillColor: Colors.red[200],
          ),
        ),
      ),
    );
  }
}
