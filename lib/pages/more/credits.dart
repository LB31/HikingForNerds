import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/global_settings.dart';

// TODO this was created only for testing purpose
class CreditsPage extends StatefulWidget {
  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Bench Icon taken from: https://www.flaticon.com/authors/freepik and created by: http://www.freepik.com"
          ),
        ),
      ],
    );
  }
}
