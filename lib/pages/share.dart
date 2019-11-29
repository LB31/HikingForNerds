import 'dart:convert';
import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart' as prefix1;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';


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
    super.initState();

    var jsonString =
        getPolyLinesAsGeoJson(
            this.widget.polylineLayerOptions.polylines
        ).serialize();

    jsonString = trimWrongPluginSyntax(jsonString);

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
                  //SimpleShare.share(uri: this.widget.exportedFile.path, subject: "route");

                  prefix1.Share.file('route', 'route.geojson', this.widget.exportedFile.readAsBytesSync(), 'application/json');
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

  static GeoJsonFeatureCollection getPolyLinesAsGeoJson(List<Polyline> polylines){
    /*var object = {
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
    };*/
    List<GeoJsonFeature> geojsonFeatures = new List<GeoJsonFeature>();

    for(Polyline polyline in polylines){
      GeoJsonFeature feature = new GeoJsonFeature<GeoJsonLine>();
      feature.type = GeoJsonFeatureType.line;
      feature.properties = {};
      feature.geometry = getCoordinatesString(polyline);
      geojsonFeatures.add(feature);
    }

    GeoJsonFeatureCollection geoJsonFeatureCollection = new GeoJsonFeatureCollection(geojsonFeatures);

    return geoJsonFeatureCollection;
  }

  static GeoJsonLine getCoordinatesString(Polyline polyline){
    GeoJsonLine geoJsonLine = new GeoJsonLine();
    GeoSerie geoSerie = new GeoSerie();
    geoSerie.type = GeoSerieType.line;
    List<GeoPoint> geoPointList = new List<GeoPoint>();
    geoSerie.name = 'random';

    for(int i = 0; i < polyline.points.length; i++){
      geoPointList.add(GeoPoint(
          latitude: polyline.points[i].latitude,
          longitude: polyline.points[i].longitude)
      );
    }

    geoSerie.geoPoints = geoPointList;
    geoJsonLine.geoSerie = geoSerie;

    return geoJsonLine;
  }

  static String trimWrongPluginSyntax(String jsonString) {
    RegExp regExp = new RegExp("\"([Tt]ype)\"(\s*):(\s*)\"([Ll]ine)\"");
    if (regExp.hasMatch(jsonString)){
      print("hallo");
      jsonString = jsonString.replaceAll(regExp, "\"type\":\"LineString\"");
    }

    return jsonString;
  }

}