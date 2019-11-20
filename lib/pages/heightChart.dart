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
    var points = HikingMapState.routePoints;
    if (foundHeights.length == 0) getRouteElevations(points, context);
    return draw();
  }

  void getRouteElevations(List<Node> points, BuildContext context) async {
    print("BAM");
    var url = "https://api.jawg.io/elevations?locations=";
    var token =
        "JrPmIVDZsukCObjipvzDgr5MWEAygaF6k5dWrIRVCYXl6mKttFjsSkgWSulMdSYs";

    for (var i = 0; i < 150; i++) {
      url +=
          points[i].latitude.toString() + "," + points[i].longitude.toString();
      if (i != 150 - 1) url += "%7C";
    }
    url += "&access-token=" + token;

    var response = await http.get(url);
    var parsedData = JSON.jsonDecode(response.body);
    List<double> allHeights = new List();
    for (var i = 0; i < parsedData.length; i++) {
      allHeights.add(parsedData[i]["elevation"]);
    }

    print("reads");
    this.foundHeights = allHeights;
    build(context);
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
