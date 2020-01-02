import 'dart:convert';
import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/geojson_export_handler.dart';
import 'package:hiking4nerds/services/gpx_export_handler.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:path_provider/path_provider.dart';

///Stateless Share Widget
///requires Routes in form of multiple node Lists
class ShareRoute extends StatelessWidget {
  final HikingRoute route;

  ShareRoute({Key key, @required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ShareConsts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: shareDialogContent(context),
    );
  }

  shareDialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(ShareConsts.padding),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(ShareConsts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ShareConsts.widgetTitle,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.share),
                  ),
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                ShareConsts.widgetDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                      onPressed: () async {
                        if (this.route == null) return;
                        String jsonString =
                            GeojsonExportHandler.parseStringFromRoute(route);
                        File exportedFile = await exportAsJson(jsonString);
                        await Share.file('route', 'route.geojson',
                            exportedFile.readAsBytesSync(), 'application/json');
                        Navigator.pop(context);
                      },
                      child: Text(ShareConsts.exportButtonGeojson),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FlatButton(
                      onPressed: () async {
                        if (this.route == null) return;
                        String gpxString =
                            GpxExportHandler.parseFromRoute(route);
                        File exportedFile = await exportAsGpx(gpxString);
                        await Share.file('route', 'route.gpx',
                            exportedFile.readAsBytesSync(), 'text/xml');
                        Navigator.pop(context);
                      },
                      child: Text(ShareConsts.exportButtonGpx),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<File> exportAsJson(String jsonString) async {
    final file = await localPath(ShareConsts.sharedFileName + '.geojson');

    return file.writeAsString(json.encode(json.decode(jsonString)));
  }

  Future<File> exportAsGpx(String gpxString) async {
    final file = await localPath(ShareConsts.sharedFileName + '.gpx');

    return file.writeAsString(gpxString);
  }

  /// returns path to local directory
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();

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

//TODO: add to localization
class ShareConsts {
  ShareConsts._();

  static const String sharedFileName = "route";

  static const double padding = 16.0;
  static const double blurRadius = 10.0;

  static const String widgetTitle = "Share";
  static const String widgetDescription = "your personal route as...";
  static const String exportButtonGeojson = "GeoJson";
  static const String exportButtonGpx = "GPX";
}
