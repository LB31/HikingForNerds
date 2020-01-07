import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/osm_key_search_bar.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:hiking4nerds/services/routeparams.dart';

class RoutePreferences extends StatefulWidget {
  final RouteParams routeParams;

  RoutePreferences({@required this.routeParams});

  @override
  _RoutePreferencesState createState() => _RoutePreferencesState();
}

class _RoutePreferencesState extends State<RoutePreferences> {
  double distance = 5.0; // default
  int selectedAltitude = 0;

  altitudeSelection() {
    List<Widget> typesBar = List();
    AltitudeType.values.forEach((v) {
      int index = v.index;
      typesBar.add(FlatButton(
        child: Text('$v'),
        color: index == selectedAltitude ? htwGreen : htwGrey,
        onPressed: () {
          setState(() {
            widget.routeParams.altitudeType = v;
            selectedAltitude = index;
          });
        },
      ));
    });
    return typesBar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Setup'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Select Route Distance',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.left,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Slider(
                            activeColor: htwGreen,
                            inactiveColor: htwBlue,
                            min: 1.0,
                            max: 30.0,
                            label: distance.toString(),
                            onChanged: (value) {
                              setState(() => distance = value);
                            },
                            value: distance,
                          ),
                        ),
                        Container(
                          width: 100.0,
                          alignment: Alignment.center,
                          child: Text('${distance.toInt()}\nKM',
                              style: Theme.of(context).textTheme.display1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 40, 10, 20),
                child: Divider(
                  color: htwGrey,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Select Points of Interest',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.left,
                  ),
                  OSMKeySearchBar(this),
                ],
              ),/*
              Padding(
                padding: EdgeInsets.fromLTRB(10, 40, 10, 20),
                child: Divider(color: htwGrey),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Select Altitude Level',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.left,
                  ),
                  Wrap(
                    children: altitudeSelection(),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 40, 10, 20),
              ),*/
            ],
          ),
          /*Container(
              child: RawMaterialButton(
                // TODO - push and calc new route
                  onPressed: () => print('Calculating ${widget.routeParams.distance.toString()} route with ${widget.routeParams.poi.length} item(s) and ${widget.routeParams.altitudeType.toString()} altitude level'),
                  child: Text('GO'),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: htwGreen,
                  padding: const EdgeInsets.all(20.0),
                ),
                alignment: Alignment.bottomCenter,
          ),*/
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width * 0.5 - 35,
            child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                heroTag: "btn-go",
                child: Icon(
                  Icons.directions_walk,
                  size: 40,
                ),
                onPressed: () => print(
                    'Calculating ${widget.routeParams.distance.toString()} route with ${widget.routeParams.poi.length} item(s) and ${widget.routeParams.altitudeType.toString()} altitude level'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
