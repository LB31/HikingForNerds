import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/more/settings.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'credits.dart';
import 'help.dart';

// TODO this class shows how to navigate to another page on the same segment
/// please modify this to your needs (remove routing in segment navigator if necessary)
class MorePage extends StatefulWidget {
  // final VoidCallback onPushCredit;
  // final VoidCallback onPushHelp;
  // final VoidCallback onPushSettings;

  // MorePage(
  //     {@required this.onPushCredit,
  //     @required this.onPushHelp,
  //     @required this.onPushSettings});

  @override
  _MorePageState createState() => _MorePageState();
}

Container decorateContent(String title, Widget widget) {
  return Container(
    decoration: BoxDecoration(
    ),
    child: Column(
      children: <Widget>[
        SizedBox(height: 10),
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

  double _totalHikingDistance = 0;

  @override
  void initState() {
    super.initState();
    retrieveTotalHikingDistance();
  }

  retrieveTotalHikingDistance(){
    SharedPreferences.getInstance().then((prefs) {
      double totalHikingDistance =
          prefs.getDouble("totalHikingDistance") ?? 0;
      if(_totalHikingDistance != totalHikingDistance){
        setState(() {
          _totalHikingDistance = totalHikingDistance;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    retrieveTotalHikingDistance();

    return Scaffold(
      appBar: AppBar(
        title: Text('More'),
      ),
      body: Center(
        child: ListView(
          //padding: const EdgeInsets.all(12),
          children: <Widget>[
          decorateContent("Total Hiking Distance", Text("${_totalHikingDistance.toString().substring(0, 5)}km")),
          decorateContent("Settings", SettingsPage()),
          makeHorizontalSpace(),
          decorateContent("Help", HelpPage()),
          makeHorizontalSpace(),
          decorateContent("Credits", CreditsPage()),
          makeHorizontalSpace(),
        ]),
      ),
    );
  }
}
