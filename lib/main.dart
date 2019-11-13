import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/home.dart';
import 'package:hiking4nerds/pages/howto.dart';
import 'package:hiking4nerds/pages/info.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => Home(),
    '/howto': (context) => HowTo(),
    '/info': (context) => Info(),
  },
));
