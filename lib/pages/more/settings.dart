import 'package:flutter/material.dart';

// TODO this was created only for testing purpose
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool checkboxValue = false;
  double sliderValue = 0;
  RangeValues sliderRange = RangeValues(2, 10);

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
                      });
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Slider"),
                  Slider(
                    value: sliderValue,
                    onChanged: (double value) {
                      setState(() {
                        sliderValue = value;
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
                      });
                    },
                    min: 0,
                    max: 15,
                    divisions: 15,
                    labels: RangeLabels(sliderRange.start.toString(), sliderRange.end.toString()),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
