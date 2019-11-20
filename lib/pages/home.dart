import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:hiking4nerds/components/hikingmap.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hiking 4 Nerds'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: <Widget>[
          HikingMap(),
          //HeightChart(),
          FabCircularMenu(
            child: Container(),
            ringColor: Colors.white30,
            ringDiameter: MediaQuery.of(context).size.width * 0.8,
            fabColor: Theme.of(context).primaryColor,
            options: <Widget>[
              IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: () {
                    Navigator.pushNamed(context, '/help');
                  },
                  iconSize: 42.0),
              IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.pushNamed(context, '/info');
                  },
                  iconSize: 42.0),
              IconButton(
                  icon: Icon(Icons.find_replace),
                  onPressed: () {
                    Navigator.pushNamed(context, '/routesetup');
                  },
                  iconSize: 42.0),
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  iconSize: 42.0),
              IconButton(
                  icon: Icon(Icons.arrow_upward),
                  onPressed: () {
                    Navigator.pushNamed(context, '/height');
                  },
                  iconSize: 42.0),
            ],
          ),
        ],
      ),
    );
  }
}
