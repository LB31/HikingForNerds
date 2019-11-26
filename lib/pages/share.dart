import 'dart:convert';
import 'dart:convert' as prefix1;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:share/share.dart';
import 'package:share/share.dart' as prefix0;
import 'package:json_to_form/json_to_form.dart';

class Share extends StatefulWidget{
  final PolylineLayerOptions polylineLayerOptions;

  Share({Key key, @required this.polylineLayerOptions}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShareState();
}

class _ShareState extends State<Share> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 2,
        itemBuilder: (context, i) {
          if (i == 0) {
            return FlatButton.icon(
                onPressed: (){

                },
                icon: Icon(Icons.add_a_photo),
                label: _buildButtonLabel('As File')
            );
          }else {
            return FlatButton.icon(
                onPressed: (){
                  var jsonFile = prefix1.json.encode(
                      getPolyLinesAsGeoJson(
                          this.widget.polylineLayerOptions.polylines
                      )
                  );
                  prefix0.Share.share(jsonFile);
                },
                icon: Icon(Icons.add_a_photo),
                label: _buildButtonLabel('Social Media')
            );
          }
        },
      ),
    );
  }

  Widget _buildButtonLabel(String buttonText){
    return Text(
      buttonText,
      style: TextStyle(
        fontSize: 18.0
      ),
    );
  }

  static Object getPolyLinesAsGeoJson(List<Polyline> polylines){
    var object = {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {},
          'geometry': {
            'type': 'LineString',
            'coordinates': getCoordinatesString(polylines)
          }
        }
      ]
    };

    return object;
  }

  static List getCoordinatesString(List<Polyline> polylines){
    /*for (Polyline polyline in polylines){

    }*/

    List<List<double>> coordinatesString = new List<List<double>>();
    Polyline polyline = polylines[0];
    for(int i = 0; i < polyline.points.length; i++){
      coordinatesString.add([
        polyline.points[i].latitude,
        polyline.points[i].longitude
      ]);
    }

    return coordinatesString;
  }
}