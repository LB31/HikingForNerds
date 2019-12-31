import 'package:flutter/material.dart';

// TODO this was created only for testing purpose
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool checkboxValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Container(
          child: Stack(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(checkboxValue.toString()),
                  Checkbox(
                    value: checkboxValue,
                    onChanged: (bool value) {
                      setState(() {
                        checkboxValue = value;
                      });
                    },
                  )
                ],
              )
            ],
          ),
        ));
  }
}
