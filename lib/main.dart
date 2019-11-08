import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/home.dart';
import 'styles.dart';

void main() => runApp(MaterialApp(
  title: "Hiking4Nerds",
  initialRoute: '/',
  routes: {
    '/': (context) => Home(),
  },
  theme: ThemeData(
      primaryColor: htwGreen,
      accentColor: Colors.black,
    iconTheme: IconThemeData(
      color: htwGreen
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: htwGreen,
    )
  ),
));
