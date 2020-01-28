import 'dart:io';

import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:hiking4nerds/services/routing/geo_utilities.dart';
import 'package:hiking4nerds/services/routing/node.dart';

/// Superclass providing basic functionality used gpx and geojson data handling
class ImportExportHandler{

  Future<File> sharedFile(String dataPath) async {
    final sharedFilePath = await FlutterAbsolutePath.getAbsolutePath(dataPath);

    File file = File(sharedFilePath);
    return file.existsSync() ? file : null;
  }

  double calculateDistance(List<Node> path){
    double distance = 0.0;
    for(int i = 0; i < path.length - 1; i++){
      distance += getDistance(path[i], path[i+1]);
    }
    return distance;
  }
}