import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/map.dart';

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
        backgroundColor: Color(0xff76B900),
      ),
      body: new Map()
    );
  }
}
