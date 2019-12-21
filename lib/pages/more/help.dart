import 'package:flutter/material.dart';

// TODO this class shows how to navigate to another segment
class HelpPage extends StatefulWidget {
  final VoidCallback onPushHistory;
  final VoidCallback onPushHistorySaveState;

  HelpPage({@required this.onPushHistory, @required this.onPushHistorySaveState});

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: Center(
        child: new ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton(
              onPressed:  widget.onPushHistory,
              child: new Text("-> history and pop more"),
            ),
            new RaisedButton(
              onPressed:  widget.onPushHistorySaveState,
              child: new Text("-> history and don't pop"),
            ),
          ],
        ),
      ),
    );
  }
}