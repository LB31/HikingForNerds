import 'package:flutter/material.dart';

// TODO this was created only for testing purpose
class Credits extends StatefulWidget {
  @override
  _CreditsState createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credits'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}