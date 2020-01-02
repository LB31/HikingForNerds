import 'dart:convert';
import 'dart:io';

import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';

class GeojsonExportHandler{

  /// parse List of Polyline objects to Geojson as String
  static String parseStringFromRoute(HikingRoute route){
    /// WORKAROUND: invocation of Method [trimWrongPluginSyntax] to trim out wrong syntax provided by plugin
    return _trimWrongPluginSyntax(
        _getGeojsonFeatureCollection(route)
            .serialize(), route.pointsOfInterest
    );
  }

  /// creates new GeoJsonFeatureCollection object containing data of route
  static GeoJsonFeatureCollection _getGeojsonFeatureCollection(HikingRoute hikingRoute){
    List<GeoJsonFeature> geojsonFeatures = new List<GeoJsonFeature>();

    geojsonFeatures.add(_createPathFeature(hikingRoute.path));
    _createPOIFeature(hikingRoute.pointsOfInterest).forEach((poi) => geojsonFeatures.add(poi));

    return new GeoJsonFeatureCollection(geojsonFeatures);
  }

  static GeoJsonFeature _createPathFeature(List<Node> path) {
    GeoJsonFeature feature = new GeoJsonFeature<GeoJsonLine>();
    feature.type = GeoJsonFeatureType.line;
    feature.properties = {};
    feature.geometry = _toGeojsonLine(path);
    return feature;
  }

  static List<GeoJsonFeature> _createPOIFeature(List<PointOfInterest> pointsOfInterest) {
    List<GeoJsonFeature> pois = new List<GeoJsonFeature<GeoJsonPoint>>();
    for(PointOfInterest pointOfInterest in pointsOfInterest){
      GeoJsonFeature poi = new GeoJsonFeature<GeoJsonPoint>();
      poi.type = GeoJsonFeatureType.point;
      poi.properties = new Map();

      //TODO: copy all tags, not just name: wirte own mapper?
      if (!pointOfInterest.tags.containsKey("name"))
        poi.properties.putIfAbsent("name", () => "POI" + pointOfInterest.id.toString());

      poi.properties.addAll(pointOfInterest.tags);
      poi.geometry = _toGeojsonPoint(pointOfInterest);

      pois.add(poi);
    }

    return pois;
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

  static GeoJsonPoint _toGeojsonPoint(PointOfInterest pointOfInterest) {
    GeoPoint geoPoint = new GeoPoint(
        latitude: pointOfInterest.latitude,
        longitude: pointOfInterest.longitude,
        id: pointOfInterest.id
    );

    return new GeoJsonPoint(
      name: "Point of Interest",
      geoPoint: geoPoint
    );
  }

  /// trim wrong syntax from geopoint package
  /// could lead to problems with polygons in geojson string
  /// pls don't ask
  static String _trimWrongPluginSyntax(String jsonString, List<PointOfInterest> pointsOfInterest) {
    //trim out wrong line feature type name
    RegExp regExp = new RegExp("\\\"([Tt]ype)\\\"(\s*):(\s*)\\\"([Ll]ine)\\\"");
    if (regExp.hasMatch(jsonString))
      jsonString = jsonString.replaceAll(regExp, "\"type\":\"LineString\"");

    //trim out wrongly placed braces
    RegExp regExp1 = new RegExp("\\\"([Ff]eatures)\\\"(\\s*):(\\s*)\\[(\s*)\\[(\\s*)\\{(\\s*)\\\"([Tt]ype)\\\"");
    if (regExp1.hasMatch(jsonString)) {
      jsonString = jsonString.replaceAll(regExp1, "\"features\":[{\"type\"");
      jsonString = jsonString.replaceAll(new RegExp("\\],\\[\\{\\\"[Tt]ype\\\""), ",{\"type\"");
      jsonString = jsonString.replaceAll(new RegExp("(\\]\\]\\})\$"), "]}");
    }

    //trim out wrong properties of pois
    RegExp regExp2 = new RegExp("\\\"([Pp]roperties)\\\"(\\s*):(\\s*)\\{\\\"name\\\"(\\s*):(\\s*)\\\"null\\\"\\}");
    var match;
    var poiIndex = -1;
    StringBuffer buffer = new StringBuffer();
    while((match = regExp2.firstMatch(jsonString)) != null && ++poiIndex < pointsOfInterest.length){
      buffer.write("\"properties\":{");
      var counter = 0;
      pointsOfInterest[poiIndex].tags.forEach((key, value) =>
          buffer.write("\"" + key + "\"" + ":" + "\"" + value + "\"" + (++counter >= pointsOfInterest[poiIndex].tags.length ? "" : ",")));
      buffer.write("}");
      jsonString = jsonString.replaceRange(match.start, match.end, buffer.toString());
      buffer.clear();
    }

    return jsonString;
  }

  //importing part
  //TODO: think about heightData and POIs
  static Future<HikingRoute> parseRouteFromPath(String dataPath) async {
    File readSharedFile = await _sharedFile(dataPath);

    GeoJsonFeatureCollection featureCollection = await featuresFromGeoJsonFile(readSharedFile, nameProperty: "null");

    return _geoJsonFeatureToRoute(featureCollection);
  }

  ///Translates parsed GeoJsonFeatureCollection to a HikingRoute
  ///NOTE: a single point in a feature collection will be interpreted as a Point of Interest
  static HikingRoute _geoJsonFeatureToRoute(GeoJsonFeatureCollection geoJsonFeatureCollection){
    List<GeoJsonFeature> features = geoJsonFeatureCollection.collection;
    HikingRoute hikingRoute = new HikingRoute(null, 0, new List<PointOfInterest>());

    for (GeoJsonFeature feature in features){
      if (feature.type == GeoJsonFeatureType.line){
        GeoJsonLine geometry = feature.geometry as GeoJsonLine;
        List<Node> nodes = new List<Node>();
        int idCounter = 0;

        for(GeoPoint geoPoint in geometry.geoSerie.geoPoints){
          nodes.add(new Node(idCounter++, geoPoint.latitude, geoPoint.longitude));
        }

        hikingRoute.path = nodes;

      }else if (feature.type == GeoJsonFeatureType.point){
        GeoJsonPoint point = feature.geometry as GeoJsonPoint;

        PointOfInterest pointOfInterest = new PointOfInterest(
          hikingRoute.pointsOfInterest.length,
          point.geoPoint.latitude,
          point.geoPoint.longitude,
          feature.properties);

        hikingRoute.pointsOfInterest.add(pointOfInterest);
      }

    }

    return hikingRoute;
  }

  static Future<File> _sharedFile(String dataPath) async {
    final sharedFilePath = await FlutterAbsolutePath.getAbsolutePath(dataPath);

    File file = File(sharedFilePath);
    return file.existsSync() ? file : null;
  }
}