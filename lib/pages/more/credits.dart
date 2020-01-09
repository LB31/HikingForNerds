import 'package:flutter/material.dart';

// TODO this was created only for testing purpose
class CreditsPage extends StatefulWidget {
  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
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