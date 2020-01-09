import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/global_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hiking4nerds/styles.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  GlobalSettings gs = GlobalSettings();

  // Design
  TextStyle textStyle = TextStyle(fontSize: 20);
  MainAxisAlignment axisAlignment = MainAxisAlignment.spaceEvenly;
  double spcaeBetweenRows = 10;

  @override
  void initState() {
    super.initState();

  }

  saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool("safeHistory", gs.safeHistory);
      prefs.setBool("useLocation", gs.useLocation);
      prefs.setString('selectedLanguage', gs.selectedLanguage);
      prefs.setString('selectedUnit', gs.selectedUnit);
      prefs.setDouble('maximumRouteLength', gs.maximumRouteLength);
    });
  }

  Text createHeading(String header) {
    return Text(
      header,
      style: textStyle,
    );
  }

  List<DropdownMenuItem<String>> buildDropdownItems(List<String> options) {
    return options.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  AlertDialog pupUpDialog(
      BuildContext context, String message, Function onConfirmation) {
    return AlertDialog(
      title: createHeading(message),
      actions: [
        FlatButton(
            child: Text("Yes"),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirmation();
            }),
        FlatButton(
            child: Text("No"),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    );
  }

  BoxDecoration addButtonDecoration() {
    return BoxDecoration(
      color: htwGrey,
      borderRadius: BorderRadius.circular(4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              // Safe History (switch)
              Row(
                mainAxisAlignment: axisAlignment,
                children: <Widget>[
                  createHeading("Safe History"),
                  Switch(
                    value: gs.safeHistory,
                    onChanged: (bool value) {
                      setState(() {
                        gs.safeHistory = value;
                        saveSettings();
                      });
                    },
                    activeColor: htwGreen,
                    inactiveTrackColor: htwGrey,
                  )
                ],
              ),
              // Use Location
              Row(
                mainAxisAlignment: axisAlignment,
                children: <Widget>[
                  createHeading("Use Location"),
                  Switch(
                    value: gs.useLocation,
                    onChanged: (bool value) {
                      setState(() {
                        gs.useLocation = value;
                        saveSettings();
                      });
                    },
                    activeColor: htwGreen,
                    inactiveTrackColor: htwGrey,
                  )
                ],
              ),
              // Language TODO
              Row(
                mainAxisAlignment: axisAlignment,
                children: <Widget>[
                  createHeading("Language"),
                  DropdownButton<String>(
                    value: gs.selectedLanguage,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: htwBlue),
                    underline: Container(
                      height: 2,
                      color: htwBlue,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        gs.selectedLanguage = newValue;
                        saveSettings();
                      });
                    },
                    items: buildDropdownItems(gs.languageOptions),
                  )
                ],
              ),
              // Units
              Row(
                mainAxisAlignment: axisAlignment,
                children: <Widget>[
                  createHeading("Units"),
                  DropdownButton<String>(
                    value: gs.selectedUnit,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: htwBlue),
                    underline: Container(
                      height: 2,
                      color: htwBlue,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        gs.selectedUnit = newValue;
                        saveSettings();
                      });
                    },
                    items: buildDropdownItems(gs.unitOptions),
                  )
                ],
              ),
              // Delete downloaded maps
              InkWell(
                  onTap: () {
                    saveSettings();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => pupUpDialog(
                        context,
                        "Are you sure you want to delete your downloaded maps?",
                        null,
                      ),
                    );
                  },
                  child: Container(
                    decoration: addButtonDecoration(),
                    child: Padding(
                      child: createHeading("Delete downloaded maps"),
                      padding: EdgeInsets.all(6.0),
                    ),
                  )),
              // Space
              SizedBox(height: spcaeBetweenRows),
              // Delete history
              InkWell(
                  onTap: () {
                    saveSettings();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => pupUpDialog(
                        context,
                        "Are you sure you want to delete your history?",
                        null,
                      ),
                    );
                  },
                  child: Container(
                    decoration: addButtonDecoration(),
                    child: Padding(
                      child: createHeading("Delete history"),
                      padding: EdgeInsets.all(6.0),
                    ),
                  )),
              // Space
              SizedBox(height: spcaeBetweenRows), //
              // Maximum route length
              // Column(
              //   mainAxisAlignment: axisAlignment,
              //   children: <Widget>[
              //     createHeading("Maximum route length"),
              //     Slider(
              //       value: gs.maximumRouteLength,
              //       onChanged: (double value) {
              //         setState(() {
              //           gs.maximumRouteLength = value;
              //           saveSettings();
              //         });
              //       },
              //       min: 0,
              //       max: 15,
              //       divisions: 15,
              //       label: gs.languageOptions.toString(),
              //     )
              //   ],
              // ),
            ],
          ),
        ));
  }
}
