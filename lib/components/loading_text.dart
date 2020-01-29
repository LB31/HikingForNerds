import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:hiking4nerds/services/localization_service.dart';

class LoadingText extends StatefulWidget {
  final bool isStatic;
  final VoidCallback mapCreated;

  LoadingText({Key key, @required this.isStatic, this.mapCreated})
      : super(key: key);

  @override
  LoadingTextState createState() => LoadingTextState();
}

class LoadingTextState extends State<LoadingText> {
  String currentText = "";
  List<String> textListEn = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
  List<String> textListGer = [
    "1de",
    "2de",
    "3de",
    "4de",
    "5de",
    "6de",
    "7de",
    "8de",
    "9de"
  ];

  @override
  void initState() {
    super.initState();
    initUpdateTextTimer();
    updateText();
  }

  void initUpdateTextTimer() {
    Timer.periodic(Duration(seconds: 4), (Timer t) => updateText());
  }

  void updateText() {
    String nextText = LocalizationService().getLocalization(
        english: textListEn[Random().nextInt(textListEn.length)],
        german: textListGer[Random().nextInt(textListEn.length)]);
    setState(() {
      currentText = nextText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(currentText);
  }
}
