import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/global_settings.dart';

/// TODO this class shows how to navigate to another segment
/// please modify this to your needs (remove routing in segment navigator if necessary)
class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(GlobalSettings().selectedLanguage.toString()), // for testing
      ],
    );
  }
    
  
}