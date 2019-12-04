import 'dart:convert';
import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/geojson_export_handler.dart';
import 'package:hiking4nerds/services/gpx_export_handler.dart';
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:path_provider/path_provider.dart';


class Share extends StatefulWidget{
  List<Node> nodeList;
  File exportedFile;
  File exportedGpxFile;

  Share({Key key, @required this.nodeList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShareState();
}

class _ShareState extends State<Share> {
  @override
  void initState() {
    super.initState();

    OsmData().calculateRoundTrip(52.510143, 13.408564, 10000, 90).then((List<Node> route){
      setState(() {
        this.widget.nodeList = route;
      });

      List<List<Node>> mockedMulipleRoutes = [this.widget.nodeList];

      String jsonString = GeojsonExportHandler.parseFromPolylines(mockedMulipleRoutes);
      var gpxString = GpxExportHandler.parseFromPolylines(mockedMulipleRoutes);

      exportAsJson(jsonString).then((File jsonFile) {
        setState(() {
          this.widget.exportedFile = jsonFile;
        });
      });

      exportAsGpx(gpxString).then((File gpxFile){
        setState(() {
          this.widget.exportedGpxFile = gpxFile;
        });
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
                  //application/xml, um das Problem mit Slack zu loesen
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
    final file = await localPath('route.geojson');

    return file.writeAsString(json.encode(json.decode(jsonString)));
  }

  Future<File> exportAsGpx(String gpxString) async{
    final file = await localPath('route.gpx');

    return file.writeAsString(gpxString);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  /// returns Promise for the existing local file or creates a new one
  Future<File> localPath(String filename) async {
    final path = await _localPath;

    File file = File('$path/$filename');
    return file.existsSync() ? file : createFile(path, filename);
  }

  File createFile(String dir, String fileName) {
    File file = new File('$dir/$fileName');
    file.createSync();
    return file;
  }
}