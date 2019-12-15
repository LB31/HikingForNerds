import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/mapwidget.dart';
import 'package:hiking4nerds/components/navbar.dart';
import 'package:hiking4nerds/styles.dart';

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
          MapWidget(isStatic: false),
        ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () { },
        child: Icon(Icons.find_replace),
        backgroundColor: htwGreen,
        elevation: 2.0,
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}