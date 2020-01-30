import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiking4nerds/components/poi_category_search_bar.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/routing/poi_category.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:hiking4nerds/services/routeparams.dart';

class RoutePreferences extends StatefulWidget {
  final RouteParamsCallback onPushRouteList;
  final RouteParams routeParams;

  RoutePreferences(
      {@required this.onPushRouteList, @required this.routeParams});

  @override
  _RoutePreferencesState createState() => _RoutePreferencesState();
}

class _RoutePreferencesState extends State<RoutePreferences> {
  int avgHikingSpeed = 12; // 12 min per km
  double distance = 5.0; // default
  int selectedAltitude = 0;
  bool distanceAsDuration = false;
  List<PoiCategory> selectedPoiCategories = List<PoiCategory>();

  altitudeSelection() {
    List<Widget> altitudeTypes = List();
    AltitudeType.values.forEach((v) {
      int index = v.index;
      altitudeTypes.add(FlatButton(
        child: Text(AltitudeTypeHelper.asString(v),
            style: TextStyle(fontSize: 16)),
        color: index == selectedAltitude ? htwGreen : htwGrey,
        onPressed: () {
          setState(() => selectedAltitude = index);
        },
      ));
    });
    return altitudeTypes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().getLocalization(english: "Route Preferences", german: "Routeneinstellungen")), 
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Text(
                      LocalizationService().getLocalization(english: "Select Route Distance", german: "Routendistanz wählen"),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600]),
                      textAlign: TextAlign.left,
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Wrap(children: <Widget>[
                      FlatButton(
                          child: Text(LocalizationService().getLocalization(english: "Distance", german: "Distanz"),
                              style: TextStyle(fontSize: 16)),
                          color: !distanceAsDuration ? htwGreen : htwGrey,
                          onPressed: () {
                            setState(() => distanceAsDuration = false);
                          }),
                      FlatButton(
                          child: Text(LocalizationService().getLocalization(english: "Time", german: "Zeit"),
                              style: TextStyle(fontSize: 16)),
                          color: distanceAsDuration ? htwGreen : htwGrey,
                          onPressed: () {
                            setState(() => distanceAsDuration = true);
                          })],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Slider(
                            activeColor: htwGreen,
                            inactiveColor: htwGrey,
                            min: 2.0,
                            max: 30.0,
                            label: distance.toString(),
                            onChanged: (value) {
                              setState(() => distance = value.roundToDouble());
                            },
                            value: distance,
                          ),
                        ),
                        Container(
                          width: 60.0,
                          alignment: Alignment.center,
                          child: Text(
                            distanceAsDuration ? '${distance.toInt() *
                                avgHikingSpeed} min' : '${distance.toInt()} km',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    if(distance > 20)
                    Center(
                      child: Text(LocalizationService().getLocalization(english: "Experimental", german: "Experimentell"),
                        style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.redAccent),),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Divider(
                  color: htwGrey,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    LocalizationService().getLocalization(english: "Select Points of Interest", german: "Wähle Sehenswürdigkeiten"),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                    textAlign: TextAlign.left,
                  ),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  PoiCategorySearchBar(
                      selectedCategories: selectedPoiCategories),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Divider(color: htwGrey),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    LocalizationService().getLocalization(english: "Select Altitude Difference", german: "Höhendifferenz wählen"),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                    textAlign: TextAlign.left,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 5)),
                  Wrap(
                    children: altitudeSelection(),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 30, 10, 20),
                child: Divider(
                  color: htwGrey,
                ),
              ),
              SizedBox(height: 100,)
            ],
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery
                .of(context)
                .size
                .width * 0.5 - 35,
            child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                  backgroundColor: htwGreen,
                  heroTag: "btn-go",
                  child: Icon(FontAwesomeIcons.check, size: 30),
                  onPressed: () {
                    widget.routeParams.distanceKm = distance;
                    widget.routeParams.poiCategories = selectedPoiCategories;
                    widget.routeParams.altitudeType =
                        AltitudeTypeHelper.fromIndex(selectedAltitude);
                    widget.onPushRouteList(widget.routeParams);
                  }),
            ),
          ),

        ],
      ),
    );
  }
}
