import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/more/settings.dart';

// TODO this class shows how to navigate to another page on the same segment
/// please modify this to your needs (remove routing in segment navigator if necessary)
class MorePage extends StatefulWidget {
  final VoidCallback onPushCredit;
  final VoidCallback onPushHelp;
  final VoidCallback onPushSettings;

  MorePage(
      {@required this.onPushCredit,
      @required this.onPushHelp,
      @required this.onPushSettings});

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('More'),
      ),
      body: Center(
          child: new SettingsPage(),

          // ButtonBar(
          //   alignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     new RaisedButton(
          //       onPressed: widget.onPushHelp,
          //       child: new Icon(Icons.help),
          //       color: Colors.green,
          //     ),
          //     new RaisedButton(
          //       onPressed: widget.onPushCredit,
          //       child: new Icon(Icons.credit_card),
          //       color: Colors.red,
          //     ),
          //     new RaisedButton(
          //       onPressed: widget.onPushSettings,
          //       child: new Icon(Icons.settings),
          //       color: Colors.blue,
          //     ),
          //   ],
          // ),
  ),
    );
  }
}
