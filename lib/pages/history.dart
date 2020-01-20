import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/localization_service.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().getLocalization(english: "History", german: "Verlauf")), 
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Text("History will be here soon."),
    );
  }
}
