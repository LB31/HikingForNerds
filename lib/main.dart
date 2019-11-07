import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/home.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => Home(),
  },
));
