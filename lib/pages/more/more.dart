import 'package:flutter/material.dart';

// TODO this class shows how to navigate to another page on the same segment
class More extends StatefulWidget {
  final VoidCallback onPushCredit;
  final VoidCallback onPushHelp;

  More({@required this.onPushCredit, @required this.onPushHelp});

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('More'),
      ),
      body: Center(
        child: new ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton(
              onPressed:  widget.onPushHelp,
              child: new Icon(Icons.help),
              color: Colors.green,
            ),
            new RaisedButton(
              onPressed:  widget.onPushCredit,
              child: new Icon(Icons.credit_card),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
