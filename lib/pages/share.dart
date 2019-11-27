import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';
import 'package:json_to_form/json_to_form.dart';
import 'package:share/share.dart' as prefix0;

class Share extends StatefulWidget{
  final PolylineLayerOptions polylineLayerOptions;
  File exportedFile;

  Share({Key key, @required this.polylineLayerOptions}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShareState();
}

class _ShareState extends State<Share> {
  @override
  void initState() {
    // This is the proper place to make the async calls
    // This way they only get called once

    // During development, if you change this code,
    // you will need to do a full restart instead of just a hot reload

    // You can't use async/await here,
    // We can't mark this method as async because of the @override
    super.initState();

    var jsonString = json.encode(
        getPolyLinesAsGeoJson(
            this.widget.polylineLayerOptions.polylines
        )
    );

    exportAsJson(jsonString).then((File result) {
      setState(() {
        this.widget.exportedFile = result;
      });
    });
  }

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
                  /*prefix0.Share.file(
                      mimeType: prefix0.ShareType.TYPE_FILE,
                      path: this.widget.exportedFile.path,
                      title: "route.json")
                  .share();*/
                  prefix0.Share.shareFile(this.widget.exportedFile, mimeType: 'application/json');
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

  Future<File> exportAsJson(String jsonString) async{
    final file = await _localFile;

    return file.writeAsString(json.encode(json.decode(jsonString)));
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    //getTemporyDirectory() - Methode fuer Cache

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    String filename = 'route.json';

    File file = File('$path/$filename');
    return file.existsSync() ? file : createFile(path, filename);
  }

  File createFile(String dir, String fileName) {
    File file = new File('$dir/$fileName');
    file.createSync();
    return file;
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