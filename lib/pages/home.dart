import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/hikingmapbox.dart';
import 'package:hiking4nerds/components/navbar.dart';

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
          MapWidget(),      
        ]),
      bottomNavigationBar: Navbar(),
    );
  }
}