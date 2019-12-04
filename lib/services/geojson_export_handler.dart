import 'package:flutter_map/flutter_map.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';

class GeojsonExportHandler{

  /// parse List of Polyline objects to Geojson as String
  static String parseFromPolylines(List<Polyline> polylines){
    /// WORKAROUND: invocation of Method [trimWrongPluginSyntax] to trim out wrong syntax provided by plugin
    return _trimWrongPluginSyntax(
        _getGeojsonFeatureCollection(polylines)
            .serialize()
    );
  }

  /// creates new GeoJsonFeatureCollection object containing data of route
  static GeoJsonFeatureCollection _getGeojsonFeatureCollection(List<Polyline> polylines){
    List<GeoJsonFeature> geojsonFeatures = new List<GeoJsonFeature>();

    for(Polyline polyline in polylines){
      GeoJsonFeature feature = new GeoJsonFeature<GeoJsonLine>();
      feature.type = GeoJsonFeatureType.line;
      feature.properties = {};
      feature.geometry = _toGeojsonLine(polyline);
      geojsonFeatures.add(feature);
    }

    GeoJsonFeatureCollection geoJsonFeatureCollection = new GeoJsonFeatureCollection(geojsonFeatures);

    return geoJsonFeatureCollection;
  }

  /// returns GeoJsonLine object representing a Route
  static GeoJsonLine _toGeojsonLine(Polyline polyline){
    GeoJsonLine geoJsonLine = new GeoJsonLine();
    GeoSerie geoSerie = new GeoSerie(
        type: GeoSerieType.line,
        name: "Route as LineString"
    );

    List<GeoPoint> geoPointList = new List<GeoPoint>();
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
}