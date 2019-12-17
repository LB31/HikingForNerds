import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/hikingmapbox.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:hiking4nerds/pages/testChart.dart';

import 'package:hiking4nerds/components/share.dart';
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';

class Home extends StatefulWidget {
  static bool chartIsHere = false;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    Home.chartIsHere = false;
    print("CHART IS HERE " + Home.chartIsHere.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Hiking 4 Nerds'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: <Widget>[
          MapWidget(isStatic: false,),
          Positioned(
            top: MediaQuery.of(context).size.height - 300,
            left: 10,
            height: 300,
            width: MediaQuery.of(context).size.width * 0.8,
            child: SelectionCallbackExample.withSampleData(),
          ),
          FabCircularMenu(
          child: Container(
            // leave empty
          ),
          ringColor: Colors.white30,
          ringDiameter: MediaQuery.of(context).size.width * 0.8,
          fabColor: Theme.of(context).primaryColor,
          options: <Widget>[
            IconButton(icon: Icon(
              Icons.help_outline),
              onPressed: () { Navigator.pushNamed(context, '/help');},
              iconSize: 42.0
            ),
            IconButton(icon: Icon(
              Icons.info_outline),
              onPressed: () { Navigator.pushNamed(context, '/info');},
              iconSize: 42.0
            ),
            IconButton(icon: Icon(
              Icons.find_replace),
              onPressed: () { Navigator.pushNamed(context, '/routesetup');},
              iconSize: 42.0
            ),
            IconButton(icon: Icon(
              Icons.settings),
              onPressed: () { Navigator.pushNamed(context, '/settings');},
              iconSize: 42.0
            ),
            IconButton(icon: Icon(
              Icons.weekend),
              onPressed: () { Navigator.pushNamed(context, '/test');},
              iconSize: 42.0
            ),
          ],
        ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RawMaterialButton(
              onPressed: () {

                //TODO: remove mock route
                HikingRoute mockRoute = HikingRoute([
                  Node(0, 52.510318, 13.4085592),
                  Node(1, 52.5102903, 13.4084606),
                  Node(2, 52.5101514, 13.4081806)
                ], 2);

                showDialog(
                    context: context,
                    builder: (BuildContext context) => Share(route: mockRoute,)
                );
              },
              child: Icon(Icons.share, color: Colors.black, size: 36.0,),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: htwGreen,
              padding: const EdgeInsets.all(5.0),
            ),
          ),],
      ),
    );
  }
}