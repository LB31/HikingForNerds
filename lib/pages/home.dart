import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:hiking4nerds/components/hikingmap.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final Color htwGreen = Color(0xff76B900);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Hiking 4 Nerds'),
        backgroundColor: htwGreen,
      ),
      body: FabCircularMenu(
        child: HikingMap(),
        ringColor: Colors.white30,
        fabColor: htwGreen,
        options: <Widget>[
          IconButton(icon: Icon(
            Icons.help_outline), onPressed: () {}, iconSize: 48.0, color: htwGreen),
          IconButton(icon: Icon(Icons.save_alt), onPressed: () {}, iconSize: 48.0, color: htwGreen),
          IconButton(icon: Icon(Icons.map), onPressed: () {}, iconSize: 48.0, color: htwGreen),
          IconButton(icon: Icon(Icons.info_outline), onPressed: () {}, iconSize: 48.0, color: htwGreen),
        ],
      ),
    );
  }
}