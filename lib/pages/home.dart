import 'package:flutter/material.dart';
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
      drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: htwGreen,
                ),
              ),
              ListTile(
                title: Text('Find Hiking Route'),
                onTap: () {},
              ),
              ListTile(
                title: Text('How to'),
                onTap: () {Navigator.pushNamed(context, '/howto');},
              ),
              ListTile(
                title: Text('Imprint'),
                onTap: () {Navigator.pushNamed(context, '/info');},
              ),
            ],
          ),
        ),
      body: HikingMap(),
    );
  }
}