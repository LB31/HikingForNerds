import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/pages/history.dart';
import 'package:hiking4nerds/services/global_settings.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hiking4nerds/styles.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  GlobalSettings gs = GlobalSettings();

  // Design, TODO: outsource to styles.dart
  TextStyle textStyle = TextStyle(fontSize: 16);
  MainAxisAlignment axisAlignment = MainAxisAlignment.spaceBetween;
  double spaceBetweenRows = 10;

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
            child: Text(LocalizationService().getLocalization(english: "Yes", german: "Ja")),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirmation();
            }),
        FlatButton(
            child: Text(LocalizationService().getLocalization(english: "No", german: "Nein")),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
      children: <Widget>[
        // Safe History
        Row(
          mainAxisAlignment: axisAlignment,
          children: <Widget>[
            createHeading(LocalizationService().getLocalization(english: "Safe History", german: "Verlauf speichern")),
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
            createHeading(LocalizationService().getLocalization(english: "Use Location", german: "Standort verwenden")),
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
        // Language
        Row(
          mainAxisAlignment: axisAlignment,
          children: <Widget>[
            createHeading(LocalizationService().getLocalization(english: "Language", german: "Sprache")),
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
                  gs.langaugeChanged();
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
            createHeading(LocalizationService().getLocalization(english: "Units", german: "Einheiten")),
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
        RaisedButton(
          color: htwGreen,
          textColor: Colors.black,
          padding: EdgeInsets.all(8.0),
          splashColor: htwGrey,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => pupUpDialog(
                context,
                LocalizationService().getLocalization(english: "Are you sure you want to delete your downloaded maps?", german: "Wollen Sie die heruntergeladenen Karten wirklich löschen?"),
                (){}, // TODO call function to delete downloaded maps
              ),
            );
          },
          child: createHeading(LocalizationService().getLocalization(english: "Delete downloaded Maps", german: "Heruntergeladene Karten löschen")),
        ),
        // Delete history
        RaisedButton(
          color: htwGreen,
          textColor: Colors.black,
          padding: EdgeInsets.all(8.0),
          splashColor: htwGrey,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => pupUpDialog(
                context,
                LocalizationService().getLocalization(english: "Are you sure you want to delete your history?", german: "Wollen Sie wirklich Ihren Verlauf löschen?"),
                (){ HistoryPage.entries.clear(); }, // TODO call function to delete history
              ),
            );
          },
          child: createHeading(LocalizationService().getLocalization(english: "Delete History", german: "Verlauf löschen")),
        ),
        // Space
        SizedBox(height: spaceBetweenRows),
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
    );
    
  }
}
