import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/location_service.dart';
import 'package:hiking4nerds/styles.dart';

import 'app.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LocationService.requestLocationPermissionIfNotAlreadyGranted()
        .then((result) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => App())
      );
    });

    return Column(children: [
      Expanded(
        child: Container(
            color: htwGreen,
            child: Image(image: AssetImage("assets/img/splash_screen.png"))),
      )
    ]);
  }
}
