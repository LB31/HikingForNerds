import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/home.dart';
import 'styles.dart';
import 'package:hiking4nerds/components/hikingmapbox.dart';

void main() => runApp(MaterialApp(
      title: "Hiking4Nerds",
      initialRoute: '/',
      routes: {
        '/': (context) => MapWidget(),
      },
      theme: ThemeData(
          primaryColor: htwGreen,
          accentColor: htwGrey,
          iconTheme: IconThemeData(color: htwGreen),
          buttonTheme: ButtonThemeData(
            buttonColor: htwGreen,
          )),
    ));
