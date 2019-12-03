import 'dart:convert';
import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:gpx/gpx.dart';
import 'package:path_provider/path_provider.dart';


class Share extends StatefulWidget{
  final PolylineLayerOptions polylineLayerOptions;
  File exportedFile;
  File exportedGpxFile;

  Share({Key key, @required this.polylineLayerOptions}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShareState();
}

class _ShareState extends State<Share> {
  @override
  void initState() {
    super.initState();

    var jsonString = getPolyLinesAsGeoJson(
            this.widget.polylineLayerOptions.polylines
        ).serialize();

    jsonString = trimWrongPluginSyntax(jsonString);

    var gpxString = getPolyLinesAsGPX(this.widget.polylineLayerOptions.polylines);

    exportAsJson(jsonString).then((File result) {
      setState(() {
        this.widget.exportedFile = result;
      });
    });

    _localPath.then((String path){
      File gpxFile = createFile(path, "route.gpx");
      gpxFile.writeAsString(gpxString);
      setState(() {
        this.widget.exportedGpxFile = gpxFile;
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
                  prefix0.Share.file('route', 'route.gpx', this.widget.exportedGpxFile.readAsBytesSync(), 'text/xml');
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

                  prefix0.Share.file('route', 'route.geojson', this.widget.exportedFile.readAsBytesSync(), 'application/json');
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
    String filename = 'route.geojson';

    File file = File('$path/$filename');
    return file.existsSync() ? file : createFile(path, filename);
  }

  File createFile(String dir, String fileName) {
    File file = new File('$dir/$fileName');
    file.createSync();
    return file;
  }

  static GeoJsonFeatureCollection getPolyLinesAsGeoJson(List<Polyline> polylines){
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

  static getPolyLinesAsGPX(List<Polyline> polylines) {
    final gpx = Gpx();
    gpx.version = '1.1';
    gpx.creator = 'Hiking4Nerds';
    gpx.metadata = Metadata(
      name: 'Personal Route',
      desc: 'exported GPX Route',
      time: DateTime.now()
    );

    gpx.trks = List<Trk>();
    for(Polyline polyline in polylines){
      gpx.trks.add(getTrkList(polyline));
    }

    return GpxWriter().asString(gpx, pretty: true);
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

  /// trim wrong syntax from geopoint package
  /// could leed to problems with polygons in geojson string
  static String trimWrongPluginSyntax(String jsonString) {
    RegExp regExp = new RegExp("\\\"([Tt]ype)\\\"(\s*):(\s*)\\\"([Ll]ine)\\\"");
    if (regExp.hasMatch(jsonString))
      jsonString = jsonString.replaceAll(regExp, "\"type\":\"LineString\"");

    RegExp regExp1 = new RegExp("\\\"([Ff]eatures)\\\"(\\s*):(\\s*)\\[(\s*)\\[(\\s*)\\{(\\s*)\\\"([Tt]ype)\\\"");
    if (regExp1.hasMatch(jsonString)) {
      jsonString = jsonString.replaceAll(regExp1, "\"features\":[{\"type\"");
      jsonString = jsonString.replaceAll(new RegExp("\\],\\[\\{\\\"[Tt]ype\\\""), ",{\"type\"");
      jsonString = jsonString.replaceAll(new RegExp("(\\]\\]\\})\$"), "]}");
    }

    return jsonString;
  }

  static Trk getTrkList(Polyline polyline) {
    Trkseg trksegs = new Trkseg();
    List<Wpt> wpts = new List<Wpt>();
    for (int i = 0; i < polyline.points.length; i++){
      wpts.add(new Wpt(
        lat: polyline.points[i].latitude,
        lon: polyline.points[i].longitude
      ));
    }

    trksegs.trkpts = wpts;
    
    Trk trk = new Trk(
      name: "route",
      desc: "route",
      trksegs: [trksegs],
    );

    return trk;
  }

}