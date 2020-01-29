import 'dart:io';

import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:hiking4nerds/services/sharing/import_export_handler.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';

import '../localization_service.dart';

class GeojsonDataHandler extends ImportExportHandler{

  static RegExp lineStringRegex = new RegExp("\\\"([Tt]ype)\\\"(\s*):(\s*)\\\"([Ll]ine)\\\"");
  static RegExp wrongBracesRegex = new RegExp("\\\"([Ff]eatures)\\\"(\\s*):(\\s*)\\[(\s*)\\[(\\s*)\\{(\\s*)\\\"([Tt]ype)\\\"");
  static RegExp propertiesRegex = new RegExp("\\\"([Pp]roperties)\\\"(\\s*):(\\s*)\\{\\\"name\\\"(\\s*):(\\s*)\\\"null\\\"\\}");
  static RegExp elevationDataRegex = new RegExp("(\\\"([Cc]oordinates)\\\"(\\s*):(\\s*))*\\[*[0-9]+\\\.?[0-9]*(\\s*),(\\s*)[0-9]+\\\.?[0-9]*");
  static RegExp threeDimensionalVectorRegex = new RegExp("\\[*[0-9]+\\\.?[0-9]*(\\s*),(\\s*)[0-9]+\\\.?[0-9]*(\\s*),(\\s*)[0-9]+\\\.?[0-9]*\\]");
  static RegExp elevationDataVectorRegex = new RegExp("[0-9]+\\\.?[0-9]*\\]");


  /// parse List of Polyline objects to Geojson as String
  String parseStringFromRoute(HikingRoute route){
    /// WORKAROUND: invocation of Method [trimWrongPluginSyntax] to trim out wrong syntax provided by plugin
    /// note that you could pass an elevation list that is longer than the passed route to add elevation data for POIs if necessary
    return _trimWrongPluginSyntax(
        _getGeojsonFeatureCollection(route).serialize(), route
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
      name: LocalizationService().getLocalization(english: "Point of Interest", german: "Sehenswürdigkeit"),
      geoPoint: geoPoint
    );
  }

  /// trim wrong syntax from geopoint package
  /// could lead to problems with polygons in geojson string
  /// pls don't ask
  String _trimWrongPluginSyntax(String jsonString, HikingRoute hikingRoute) {
    List<PointOfInterest> pointsOfInterest = hikingRoute.pointsOfInterest;
    List<double> elevations = hikingRoute.elevations;
    List<Node> path = hikingRoute.path;

    //trim out wrong line feature type name
    if (lineStringRegex.hasMatch(jsonString))
      jsonString = jsonString.replaceAll(lineStringRegex, "\"type\":\"LineString\"");

    //trim out wrongly placed braces
    if (wrongBracesRegex.hasMatch(jsonString)) {
      jsonString = jsonString.replaceAll(wrongBracesRegex, "\"features\":[{\"type\"");
      jsonString = jsonString.replaceAll(new RegExp("\\],\\[\\{\\\"[Tt]ype\\\""), ",{\"type\"");
      jsonString = jsonString.replaceAll(new RegExp("(\\]\\]\\})\$"), "]}");
    }

    //trim out wrong properties of pois
    var match;
    var poiIndex = -1;
    StringBuffer buffer = new StringBuffer();
    while((match = propertiesRegex.firstMatch(jsonString)) != null && ++poiIndex < pointsOfInterest.length){
      buffer.write("\"properties\":{");
      var counter = 0;
      pointsOfInterest[poiIndex].tags.forEach((key, value) =>
          buffer.write("\"" + key + "\"" + ":" + "\"" + value + "\"" + (++counter >= pointsOfInterest[poiIndex].tags.length ? "" : ",")));
      buffer.write("}");
      jsonString = jsonString.replaceRange(match.start, match.end, buffer.toString());
      buffer.clear();
    }

    //add elevation data
    var matchCoordinate;
    var lastSubstringIndex = 0;
    var elevationIndex = -1;
    while((matchCoordinate = elevationDataRegex.firstMatch(jsonString.substring(lastSubstringIndex))) != null && ++elevationIndex < path.length){
      double elevation = (elevationIndex < elevations.length) ? elevations?.elementAt(elevationIndex) : 0.0;
      jsonString = jsonString.substring(0, lastSubstringIndex + matchCoordinate.end) + "," + elevation.toString() + jsonString.substring(lastSubstringIndex + matchCoordinate.end);
      lastSubstringIndex += matchCoordinate.end + elevation.toString().length + 1;
    }

    return jsonString;
  }

  //importing part
  /// read geojson Data from file
  /// the reason for not providing a geojson string as parameter is a problem with escape parameters in the plugin
  Future<HikingRoute> parseRouteFromFile(File readSharedFile) async {
    GeoJsonFeatureCollection featureCollection = await featuresFromGeoJsonFile(readSharedFile, nameProperty: "null");

    HikingRoute hikingRoute = _geoJsonFeatureToRoute(featureCollection);
    hikingRoute.totalLength = calculateDistance(hikingRoute.path);
    
    String jsonDataString = await readSharedFile.readAsString();
    hikingRoute.elevations = extractElevations(jsonDataString);

    return hikingRoute;
  }

  ///Translates parsed GeoJsonFeatureCollection to a HikingRoute
  ///NOTE: a single feature represented as point in a feature collection will be interpreted as a POI
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

  ///helper method extract elevations from three dimensional representation
  List<double> extractElevations(String jsonDataString) {

    //extract three dimensional vectors in string
    List<double> elevations = new List<double>();
    var matches = threeDimensionalVectorRegex.allMatches(jsonDataString);
    for(Match match in matches){
      String vectorString = jsonDataString.substring(match.start, match.end);
      Match elevationMatch = elevationDataVectorRegex.firstMatch(vectorString);
      elevations.add(double.parse(vectorString.substring(elevationMatch.start, elevationMatch.end - 1)));
    }

    return elevations;
  }

}