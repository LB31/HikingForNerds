import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool checkboxValue = false;
  double sliderValue = 0;

  double rangeLeft;
  double rangeRight;
  RangeValues sliderRange;
  
  bool switchValue = false;


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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Switch"),
                  Switch(
                    value : switchValue,
                    onChanged: (bool value){
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
