import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hiking4nerds/styles.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool safeHistory = true;
  bool useLocation = true;
  List<String> languageOptions = ["ENG", "DE"];
  String selectedLanguage = "ENG"; // TODO load from initialize
  List<String> unitOptions = ["km", "mi"];
  String selectedUnit = "km"; // TODO load from initialize
  double maximumRouteLength = 5;

  // Design
  TextStyle textStyle = TextStyle(fontSize: 20);
  MainAxisAlignment axisAlignment = MainAxisAlignment.spaceEvenly;
  double spcaeBetweenRows = 10;

  bool checkboxValue = false;
  double sliderValue = 0;

  double rangeLeft;
  double rangeRight;
  RangeValues sliderRange;

  bool switchValue = false;
  String dropdownValue = "One";

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  //Loading counter value on start
  loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      checkboxValue = (prefs.getBool('checkboxValue') ?? false);
      sliderValue = (prefs.getDouble('sliderValue') ?? 0);
      // RangeValues hack
      rangeLeft = (prefs.getDouble('rangeLeft') ?? 2);
      rangeRight = (prefs.getDouble('rangeRight') ?? 10);
      sliderRange = new RangeValues(rangeLeft, rangeRight);

      switchValue = (prefs.getBool('switchValue') ?? false);
    });
  }

  saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool("checkboxValue", checkboxValue);
      prefs.setDouble('sliderValue', sliderValue);

      prefs.setDouble("rangeLeft", sliderRange.start);
      prefs.setDouble("rangeRight", sliderRange.end);

      prefs.setBool("switchValue", switchValue);
    });
  }

  Text createHeader(String header) {
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
      title: createHeader(message),
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
                  createHeader("Safe History"),
                  Switch(
                    value: safeHistory,
                    onChanged: (bool value) {
                      setState(() {
                        safeHistory = value;
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
                  createHeader("Use Location"),
                  Switch(
                    value: useLocation,
                    onChanged: (bool value) {
                      setState(() {
                        useLocation = value;
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
                  createHeader("Language"),
                  DropdownButton<String>(
                    value: selectedLanguage,
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
                        selectedLanguage = newValue;
                      });
                    },
                    items: buildDropdownItems(languageOptions),
                  )
                ],
              ),
              // Units
              Row(
                mainAxisAlignment: axisAlignment,
                children: <Widget>[
                  createHeader("Units"),
                  DropdownButton<String>(
                    value: selectedUnit,
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
                        selectedUnit = newValue;
                      });
                    },
                    items: buildDropdownItems(unitOptions),
                  )
                ],
              ),
              // Delete downloaded maps
              InkWell(
                  onTap: () {
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
                      child: createHeader("Delete downloaded maps"),
                      padding: EdgeInsets.all(6.0),
                    ),
                  )),
              SizedBox(height: spcaeBetweenRows),
              // Delete history
              InkWell(
                  onTap: () {
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
                      child: createHeader("Delete history"),
                      padding: EdgeInsets.all(6.0),
                    ),
                  )),
              SizedBox(height: spcaeBetweenRows),
              // Maximum route length
              Column(
                mainAxisAlignment: axisAlignment,
                children: <Widget>[
                  createHeader("Maximum route length"),
                  Slider(
                    value: maximumRouteLength,
                    onChanged: (double value) {
                      setState(() {
                        maximumRouteLength = value;
                        saveSettings();
                      });
                    },
                    min: 0,
                    max: 15,
                    divisions: 15,
                    label: "$maximumRouteLength",
                  )
                ],
              ),

Spacer(),
              // Checkbox example
              Row(
                mainAxisAlignment: axisAlignment,
                children: <Widget>[
                  Text(checkboxValue.toString()),
                  Checkbox(
                    value: checkboxValue,
                    onChanged: (bool value) {
                      setState(() {
                        checkboxValue = value;
                        saveSettings();
                      });
                    },
                  )
                ],
              ),
              // Slider example
              Row(
                mainAxisAlignment: axisAlignment,
                children: <Widget>[
                  Text("Slider Persistent"),
                  Slider(
                    value: sliderValue,
                    onChanged: (double value) {
                      setState(() {
                        sliderValue = value;
                        saveSettings();
                      });
                    },
                    min: 0,
                    max: 15,
                    divisions: 5,
                    label: "$sliderValue",
                  )
                ],
              ),
              // Range slider example
              Row(
                mainAxisAlignment: axisAlignment,
                children: <Widget>[
                  Text("Range Slider"),
                  RangeSlider(
                    values: sliderRange,
                    onChanged: (RangeValues range) {
                      setState(() {
                        sliderRange = range;
                        saveSettings();
                      });
                    },
                    min: 0,
                    max: 15,
                    divisions: 15,
                    labels: RangeLabels(sliderRange.start.toString(),
                        sliderRange.end.toString()),
                  )
                ],
              ),
              // Switch example
              Row(
                mainAxisAlignment: axisAlignment,
                children: <Widget>[
                  Text("Switch"),
                  Switch(
                    value: switchValue,
                    onChanged: (bool value) {
                      setState(() {
                        switchValue = value;
                        saveSettings();
                      });
                    },
                    activeColor: Color(0xFF00FF00),
                    inactiveTrackColor: Color(0xFFFF0000),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
