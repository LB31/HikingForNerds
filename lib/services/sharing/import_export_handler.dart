import 'dart:convert';
import 'dart:io';

import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';
import 'package:hiking4nerds/services/sharing/geojson_data_handler.dart';
import 'package:hiking4nerds/services/sharing/gpx_data_handler.dart';

/// Superclass providing basic functionality used gpx and geojson data handling
class ImportExportHandler{

  //TODO: change the if else decision which handler should be instantiated when the bug in FlutterAbsolutePath Plugin is fixed
  Future<HikingRoute> importRouteFromUri(String uriPath) async {
    File readSharedFile = await _sharedFile(uriPath);

    String fileContent = await readSharedFile.readAsString();
    if (fileContent.startsWith("<?xml"))
      return await new GpxDataHandler().parseRouteFromXmlString(fileContent);
    else
      return await new GeojsonDataHandler().parseRouteFromFile(readSharedFile);

  }

  double calculateDistance(List<Node> path){
    double distance = 0.0;
    for(int i = 0; i < path.length - 1; i++){
      distance += OsmData.getDistance(path[i], path[i+1]);
    }
    return distance;
  }

  Future<File> _sharedFile(String dataPath) async {
    final sharedFilePath = await FlutterAbsolutePath.getAbsolutePath(dataPath);

    File file = File(sharedFilePath);
    return file.existsSync() ? file : null;
  }
}