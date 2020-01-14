import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/more/settings.dart';
import 'package:hiking4nerds/styles.dart';

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
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          blurRadius: 1,
          offset: Offset(0, 1),
        )
      ],
    ),
    child: Column(
      children: <Widget>[
        SizedBox(height: 10),
        Align(
          alignment: Alignment(-0.8, 0),
          child: Text(title, style: TextStyle(fontSize: 20, color: htwBlue)),
        ),
        widget,
        SizedBox(height: 10),
      ],
    ),
  );
}

SizedBox makeHorizontalSpace(){
  return SizedBox(height: 10);
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('More'),
      ),
      body: Center(
        child: ListView(
          //padding: const EdgeInsets.all(12),
          children: <Widget>[
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
