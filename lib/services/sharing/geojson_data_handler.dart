import 'dart:io';

import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:hiking4nerds/services/sharing/import_export_handler.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';

class GeojsonDataHandler extends ImportExportHandler{

  /// parse List of Polyline objects to Geojson as String
  String parseStringFromRoute(HikingRoute route){
    /// WORKAROUND: invocation of Method [trimWrongPluginSyntax] to trim out wrong syntax provided by plugin
    /// note that you could pass an elevation list that is longer than the passed route to add elevation data for POIs if necessary
    return _trimWrongPluginSyntax(
        _getGeojsonFeatureCollection(route).serialize(),
        route.pointsOfInterest,
        route.elevations
    );
  }

  /// creates new GeoJsonFeatureCollection object containing data of route
  GeoJsonFeatureCollection _getGeojsonFeatureCollection(HikingRoute hikingRoute){
    List<GeoJsonFeature> geojsonFeatures = new List<GeoJsonFeature>();

    geojsonFeatures.add(_createPathFeature(hikingRoute.path, hikingRoute.elevations));
    _createPOIFeature(hikingRoute.pointsOfInterest).forEach((poi) => geojsonFeatures.add(poi));

    return new GeoJsonFeatureCollection(geojsonFeatures);
  }

  GeoJsonFeature _createPathFeature(List<Node> path, List<double> elevations) {
    GeoJsonFeature feature = new GeoJsonFeature<GeoJsonLine>();
    feature.type = GeoJsonFeatureType.line;
    feature.properties = {};
    feature.geometry = _toGeojsonLine(path);
    return feature;
  }

  List<GeoJsonFeature> _createPOIFeature(List<PointOfInterest> pointsOfInterest) {
    List<GeoJsonFeature> pois = new List<GeoJsonFeature<GeoJsonPoint>>();
    for(PointOfInterest pointOfInterest in pointsOfInterest){
      GeoJsonFeature poi = new GeoJsonFeature<GeoJsonPoint>();
      poi.type = GeoJsonFeatureType.point;
      poi.properties = new Map();

      if (!pointOfInterest.tags.containsKey("name"))
        poi.properties.putIfAbsent("name", () => "POI" + pointOfInterest.id.toString());

      poi.properties.addAll(pointOfInterest.tags);
      poi.geometry = _toGeojsonPoint(pointOfInterest);

      pois.add(poi);
    }

    return pois;
  }

  /// returns GeoJsonLine object representing a Route
  GeoJsonLine _toGeojsonLine(List<Node> nodes){
    GeoJsonLine geoJsonLine = new GeoJsonLine();
    GeoSerie geoSerie = new GeoSerie(
        type: GeoSerieType.line,
        name: "Route as LineString"
    );

    List<GeoPoint> geoPointList = new List<GeoPoint>();
    for(int i = 0; i < nodes.length; i++){
      geoPointList.add(GeoPoint(
          latitude: nodes[i].latitude,
          longitude: nodes[i].longitude,)
      );
    }

    geoSerie.geoPoints = geoPointList;
    geoJsonLine.geoSerie = geoSerie;

    return geoJsonLine;
  }

  GeoJsonPoint _toGeojsonPoint(PointOfInterest pointOfInterest) {
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
  String _trimWrongPluginSyntax(String jsonString, List<PointOfInterest> pointsOfInterest, List<double> elevations) {
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

    //add elevation data
    RegExp regExp3 = new RegExp("(\\\"([Cc]oordinates)\\\"(\\s*):(\\s*))*\\[*[0-9]+\\\.?[0-9]*(\\s*),(\\s*)[0-9]+\\\.?[0-9]*");
    var matchCoordinate;
    var lastSubstringIndex = 0;
    var elevationIndex = -1;
    while((matchCoordinate = regExp3.firstMatch(jsonString.substring(lastSubstringIndex))) != null && ++elevationIndex < elevations.length){
      jsonString = jsonString.substring(0, lastSubstringIndex + matchCoordinate.end) + "," + elevations[elevationIndex].toString() + jsonString.substring(lastSubstringIndex + matchCoordinate.end);
      lastSubstringIndex += matchCoordinate.end + elevations[elevationIndex].toString().length + 1;
    }

    return jsonString;
  }

  //importing part
  Future<HikingRoute> parseRouteFromPath(String dataPath) async {
    File readSharedFile = await sharedFile(dataPath);

    GeoJsonFeatureCollection featureCollection = await featuresFromGeoJsonFile(readSharedFile, nameProperty: "null");
    GeoJson geo = new GeoJson();
    //TODO. search for height data in json string seperately (because geojson plugin sucks)

    HikingRoute route = _geoJsonFeatureToRoute(featureCollection);
    route.totalLength = calculateDistance(route.path);

    return route;
  }

  ///Translates parsed GeoJsonFeatureCollection to a HikingRoute
  ///NOTE: a single point in a feature collection will be interpreted as a Point of Interest
  HikingRoute _geoJsonFeatureToRoute(GeoJsonFeatureCollection geoJsonFeatureCollection){
    List<GeoJsonFeature> features = geoJsonFeatureCollection.collection;
    HikingRoute hikingRoute = new HikingRoute(null, 0, new List<PointOfInterest>());

    for (GeoJsonFeature feature in features){
      if (feature.type == GeoJsonFeatureType.line){
        GeoJsonLine geometry = feature.geometry as GeoJsonLine;
        List<Node> nodes = new List<Node>();
        List<double> elevations = new List<double>();
        int idCounter = 0;

        //TODO: check if elevation here is not null (because plugin might do bullshit?)
        for(GeoPoint geoPoint in geometry.geoSerie.geoPoints){
          nodes.add(new Node(idCounter++, geoPoint.latitude, geoPoint.longitude));
          elevations.add(geoPoint.altitude);
        }

        hikingRoute.path = nodes;
        hikingRoute.elevations = elevations;

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

    if (hikingRoute.pointsOfInterest.isEmpty) hikingRoute.pointsOfInterest = null;

    return hikingRoute;
  }


}