import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/navbar.dart';

class Route extends StatefulWidget {
  @override
  _RouteState createState() => _RouteState();
}

class _RouteState extends State<Route> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}