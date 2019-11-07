import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hiking4nerds/services/map_service.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  final Color htwGreen = Color(0xff76B900);

  void loadMap() async {
    MapService ms = MapService();
    await ms.updateCurrentLocation();
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    super.initState();
    loadMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: htwGreen,
        title: Text(' Loading Hiking 4 Nerds'),
        elevation: 0,
      ),
      body: Center(
        child:  SpinKitCubeGrid(
          color: Colors.white,
          size: 80.0,
        ),
      ),
    );
  }
}
