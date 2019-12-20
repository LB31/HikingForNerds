import 'package:flutter/material.dart';
import 'package:hiking4nerds/styles.dart';

import 'app.dart';

void main() => runApp(MaterialApp(
      title: "Hiking4Nerds",
      theme: ThemeData(
          primaryColor: htwGreen,
          accentColor: htwGrey,
          iconTheme: IconThemeData(color: htwGreen),
          buttonTheme: ButtonThemeData(
            buttonColor: htwGreen,
          )),
      home: App(),
    ));
