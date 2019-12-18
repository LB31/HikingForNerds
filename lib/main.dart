import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/home.dart';
import 'package:hiking4nerds/pages/setup/locationselection.dart';
import 'package:hiking4nerds/pages/route/route.dart' as Route;
import 'package:hiking4nerds/pages/settings/settings.dart' as Settings;
import 'package:hiking4nerds/styles.dart';

void main() => runApp(MaterialApp(
      title: "Hiking4Nerds",
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/plan': (context) => LocationSelection(),
        '/route': (context) => Route.Route(),
        '/settings': (context) => Settings.Settings(),
      },
      theme: ThemeData(
          primaryColor: htwGreen,
          accentColor: htwGrey,
          iconTheme: IconThemeData(color: htwGreen),
          buttonTheme: ButtonThemeData(
            buttonColor: htwGreen,
          ),
    )));