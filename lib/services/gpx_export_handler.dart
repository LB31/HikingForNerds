import 'dart:ui';

import 'package:xml/xml.dart';

import 'package:gpx/gpx.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';

class GpxExportHandler{

  /// parse List of Polyline objects to Gpx as String
  static String parseFromRoute(HikingRoute route){
    final gpx = Gpx();
    gpx.version = '1.1';
    gpx.creator = 'Hiking4Nerds';
    gpx.metadata = Metadata(
        name: 'Personal Route',
        desc: 'exported GPX Route',
        time: DateTime.now()
    );

    gpx.rtes = new List<Rte>();
    gpx.rtes.add(_getRoute(route.path, route.elevations));
    gpx.trks.add(_getPOIs(route.pointsOfInterest));


    return GpxWriter().asString(gpx, pretty: true);
    /*return _insertPOITags(
      GpxWriter().asXml(gpx)
    );*/
  }

  static HikingRoute parseRouteFromString(String xmlGpxString){
    Gpx gpxData = GpxReader().fromString(xmlGpxString);

    List<Node> path = new List<Node>();
    List<double> elevations = new List<double>();
    for (Rte rte in gpxData.rtes){
      int counter = 0;

      rte.rtepts.forEach((wpt) {
        path.add(new Node(counter++, wpt.lat, wpt.lon));
        elevations.add(wpt.ele);
      });
    }

    return new HikingRoute(path, null, null, elevations);
  }

  ///returns a Rte (Route) Object containing Wpts
  ///one tracksegment containing multiple Waypoint objects
  static Rte _getRoute(List<Node> nodes, List<double> elevations) {
    List<Wpt> wpts = new List<Wpt>();
    for (int i = 0; i < nodes.length; i++){
      wpts.add(new Wpt(lat: nodes[i].latitude, lon: nodes[i].longitude, ele: (i < elevations.length ? elevations[i] : 0)));
    }

    return new Rte(
      name: "route",
      desc: "route containing waypoints",
      rtepts: wpts,
    );
  }

  static Trk _getPOIs(List<PointOfInterest> pointsOfInterest){
    List<Wpt> wpts = new List<Wpt>();
    for (PointOfInterest poi in pointsOfInterest){
      wpts.add(new Wpt(
          lat: poi.latitude,
          lon: poi.longitude,
          desc: "POI"));
    }

    return new Trk(
      name: "pois",
      desc: "contains pois of route",
      trksegs: [new Trkseg(trkpts: wpts)],
    );
  }
/*
  static String _insertPOITags(XmlNode gpxXML) {
    final builder = XmlBuilder();
    List<XmlNode> xmlNodes;
    while ((xmlNodes = gpxXML.children).isNotEmpty){
      for(XmlNode xmlNode in xmlNodes){
        xmlNode.attributes
            .where((attribute) => attribute.name.toString() == "desc")
            .map((attribute) => new XmlAttribute("extensions"));
        if (xmlNode.attributes.)
      }
    }
    var type = gpxXML.nodeType;

    builder.text(gpxXML);
  }*/
}