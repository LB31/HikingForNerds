import 'dart:convert';
import 'dart:io';

import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';

class GeojsonExportHandler{

  /// parse List of Polyline objects to Geojson as String
  static String parseFromPolylines(HikingRoute route){
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
    if (regExp2.hasMatch(jsonString)){
      var allMatches = regExp2.allMatches(jsonString);
      assert(allMatches.length == pointsOfInterest.length);
      var matchesList = allMatches.toList();

      for(int i = 0; i < matchesList.length; i++){
        StringBuffer buffer = new StringBuffer();
        buffer.write("\"properties\":{");
        var counter = 0;
        pointsOfInterest[i].tags.forEach((key, value) =>
          buffer.write("\"" + key + "\"" + ":" + "\"" + value + "\"" + (++counter >= pointsOfInterest[i].tags.length ? "" : ",")));
        buffer.write("}");
        jsonString = jsonString.replaceRange(matchesList[i].start, matchesList[i].end, buffer.toString());
      }
    }


    return jsonString;
  }

  //importing part
  //TODO: think about heightData and POIs
  static Future<HikingRoute> parseRouteFromPath(File dataFile) async {
    GeoJsonFeatureCollection featureCollection = await featuresFromGeoJsonFile(dataFile, nameProperty: "null");

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
}