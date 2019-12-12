import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/navbar.dart';

class Routesetup extends StatefulWidget {
  @override
  _RoutesetupState createState() => _RoutesetupState();
}

class _RoutesetupState extends State<Routesetup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Setup'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomNavigationBar: Navbar(),
    );
  }
}