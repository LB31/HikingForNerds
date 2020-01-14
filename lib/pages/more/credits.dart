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
    return Scaffold(
      appBar: AppBar(
        title: Text('Credits'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Text(GlobalSettings().safeHistory.toString()), // for testing
    );
  }
}