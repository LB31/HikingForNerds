import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/home.dart';
import 'package:hiking4nerds/pages/help.dart';
import 'package:hiking4nerds/pages/info.dart';
import 'package:hiking4nerds/pages/routesetup.dart';
import 'package:hiking4nerds/pages/settings.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:hiking4nerds/pages/heightChart.dart';
import 'package:hiking4nerds/pages/testChart.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Hiking4Nerds",
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/height': (context) => HeightChart(),
        '/chart': (context) => SelectionLineHighlight.withSampleData(),
      },
      theme: ThemeData(
          primaryColor: htwGreen,
          accentColor: htwGrey,
          iconTheme: IconThemeData(color: htwGreen),
          buttonTheme: ButtonThemeData(
            buttonColor: htwGreen,
          )),
    ));