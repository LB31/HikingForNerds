import 'package:flutter/material.dart';

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
          child: Text("Developed by:\nJakub, Philipp, Mario, Robin, Leonid, Patrik, Roman\nsupvervised by Prof. Lenz\n2020" 
          ),
        ),
      ],
    );
  }
}
