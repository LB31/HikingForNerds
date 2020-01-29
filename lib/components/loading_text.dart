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
  List<String> textListEn = [
    "Fernglas wird eingepackt",
    "Wanderschuhe werden abgestaubt",
    "Suche nach optimaler Wegbeschaffenheit",
    "Wanderstöcke werden geschnitzt",
    "Reiseproviant wird zubereitet",
    "Wegweiser werden aufgestellt",
    "Wasserflaschen werden aufgefüllt",
    "Sonnencreme wird eingepackt",
    "Regenjacke wird gesucht",
    "Schnürsenkel werden festgezogen",
    "Schuhcreme wird aufgetragen",
    "Wanderwege werden gereinigt",
    "Wanderstock wird eingeölt",
    "Wanderlieder werden einstudiert",
  ];
  List<String> textListGer = [
    "Binoculars are being packed",
    "Hiking shoes are dusted off",
    "Search for optimal road conditions",
    "Walking sticks are carved",
    "Travelling provisions are being prepared",
    "Signposts are put up",
    "Water bottles are filled up",
    "Sunscreen is packed up",
    "Looking for a rain jacket",
    "Laces are tightened",
    "Shoe polish is applied",
    "Hiking trails are cleaned",
    "Walking stick is oiled",
    "Hiking songs are rehearsed",
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
      currentText = nextText + "..";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(currentText, style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600]),
      textAlign: TextAlign.center,);
  }
}
