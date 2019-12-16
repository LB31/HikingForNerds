import 'dart:convert';
import 'dart:io';

import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:hiking4nerds/services/route.dart';

class GeojsonExportHandler{

  /// parse List of Polyline objects to Geojson as String
  static String parseFromPolylines(List<Node> nodes){
    /// WORKAROUND: invocation of Method [trimWrongPluginSyntax] to trim out wrong syntax provided by plugin
    return _trimWrongPluginSyntax(
        _getGeojsonFeatureCollection(nodes)
            .serialize()
    );
  }

  /// creates new GeoJsonFeatureCollection object containing data of route
  static GeoJsonFeatureCollection _getGeojsonFeatureCollection(List<Node> nodes){
    List<GeoJsonFeature> geojsonFeatures = new List<GeoJsonFeature>();

    GeoJsonFeature feature = new GeoJsonFeature<GeoJsonLine>();
    feature.type = GeoJsonFeatureType.line;
    feature.properties = {};
    feature.geometry = _toGeojsonLine(nodes);
    geojsonFeatures.add(feature);

    GeoJsonFeatureCollection geoJsonFeatureCollection = new GeoJsonFeatureCollection(geojsonFeatures);

    return geoJsonFeatureCollection;
  }

  /// returns GeoJsonLine object representing a Route
  static GeoJsonLine _toGeojsonLine(List<Node> nodes){
    GeoJsonLine geoJsonLine = new GeoJsonLine();
    GeoSerie geoSerie = new GeoSerie(
        type: GeoSerieType.line,
        name: "Route as LineString"
    );

    List<GeoPoint> geoPointList = new List<GeoPoint>();
    for(int i = 0; i < nodes.length; i++){
      geoPointList.add(GeoPoint(
          latitude: nodes[i].latitude,
          longitude: nodes[i].longitude)
      );
    }

    geoSerie.geoPoints = geoPointList;
    geoJsonLine.geoSerie = geoSerie;

    return geoJsonLine;
  }

  /// trim wrong syntax from geopoint package
  /// could lead to problems with polygons in geojson string
  /// pls don't ask
  static String _trimWrongPluginSyntax(String jsonString) {
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

  //TODO: think about heightData and POIs
  static Future<HikingRoute> parseRouteFromPath(String dataPath) async {
    File readSharedFile = await _sharedFile(dataPath);

    GeoJsonFeatureCollection featureCollection = await featuresFromGeoJsonFile(readSharedFile, nameProperty: "null");

    //you could export multiple routes
    return _geoJsonFeatureToRoute(featureCollection)[0];
  }

  static List<HikingRoute> _geoJsonFeatureToRoute(GeoJsonFeatureCollection geoJsonFeatureCollection){
    List<GeoJsonFeature> features = geoJsonFeatureCollection.collection;
    List<HikingRoute> routes = List<HikingRoute>();

    for (GeoJsonFeature feature in features){
      if (feature.type == GeoJsonFeatureType.line){
        GeoJsonLine geometry = feature.geometry as GeoJsonLine;
        List<Node> nodes = new List<Node>();
        int idCounter = 0;

        for(GeoPoint geoPoint in geometry.geoSerie.geoPoints){
          nodes.add(new Node(idCounter++, geoPoint.latitude, geoPoint.longitude));
        }

        routes.add(HikingRoute(nodes, null));
      }
    }

    return routes;
  }

  static Future<File> _sharedFile(String dataPath) async {
    final sharedFilePath = await FlutterAbsolutePath.getAbsolutePath(dataPath);

    File file = File(sharedFilePath);
    return file.existsSync() ? file : null;
  }
}