import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/more/settings.dart';
import 'package:hiking4nerds/services/localization_service.dart';

import 'package:hiking4nerds/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'credits.dart';
import 'help.dart';

class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

Container decorateContent(String title, Widget widget) {
  return Container(
    child: Column(
      children: <Widget>[
        makeHorizontalSpace(),
        Align(
          alignment: Alignment(-0.8, 0),
          child: Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
        ),
        widget,
        Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Divider(
                  color: htwGrey,
                ),
              ),
      ],
    ),
  );
}

SizedBox makeHorizontalSpace(){
  return SizedBox(height: 10);
}

class _MorePageState extends State<MorePage> {

  double _totalHikingDistance = 0.0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs)  {
      _totalHikingDistance = prefs.getDouble("totalHikingDistance") ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().getLocalization(english: "More", german: "Mehr")), 
      ),
      body: Center(
        child: ListView(
          //padding: const EdgeInsets.all(12),
          children: <Widget>[
          decorateContent("Total Hiking Distance", Text("${_totalHikingDistance.toStringAsFixed(2)} km")),
          decorateContent(LocalizationService().getLocalization(english: "Settings", german: "Einstellungen"), SettingsPage()),
          makeHorizontalSpace(),
          decorateContent(LocalizationService().getLocalization(english: "Help", german: "Hilfe"), HelpPage()),
          makeHorizontalSpace(),
          decorateContent(LocalizationService().getLocalization(english: "Credits", german: "Über"), CreditsPage()), // how would you translate credits?
          makeHorizontalSpace(),
        ]),
      ),
    );
  }
}
