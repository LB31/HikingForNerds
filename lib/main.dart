import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/home.dart';
import 'package:hiking4nerds/pages/help.dart';
import 'package:hiking4nerds/pages/info.dart';
import 'package:hiking4nerds/pages/routesetup.dart';
import 'package:hiking4nerds/pages/settings.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:hiking4nerds/pages/plan/locationselection.dart';

void main() => runApp(MaterialApp(
      title: "Hiking4Nerds",
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/info': (context) => Info(),
        '/help': (context) => Help(),
        '/routesetup': (context) => LocationSelection(),
        '/settings': (context) => Settings(),
      },
      theme: ThemeData(
          primaryColor: htwGreen,
          accentColor: htwGrey,
          iconTheme: IconThemeData(color: htwGreen),
          buttonTheme: ButtonThemeData(
            buttonColor: htwGreen,
          ),
    )));