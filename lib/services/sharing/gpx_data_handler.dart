import 'dart:convert';
import 'dart:io';

import 'package:hiking4nerds/services/sharing/import_export_handler.dart';

import 'package:gpx/gpx.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';

class GpxDataHandler extends ImportExportHandler{

  //export part
  /// parse List of Polyline objects to Gpx as String
  String parseStringFromRoute(HikingRoute route){
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
  }

  ///returns a Rte (Route) Object containing Wpts
  ///one tracksegment containing multiple Waypoint objects
  Rte _getRoute(List<Node> nodes, List<double> elevations) {
    List<Wpt> wpts = new List<Wpt>();
    for (int i = 0; i < nodes.length; i++){
      Wpt wpt = new Wpt(lat: nodes[i].latitude, lon: nodes[i].longitude);
      if (i < elevations.length) wpt.ele = elevations[i];
      wpts.add(wpt);
    }

    return new Rte(
      name: "route",
      desc: "route containing waypoints",
      rtepts: wpts,
    );
  }

  Trk _getPOIs(List<PointOfInterest> pointsOfInterest){
    List<Wpt> wpts = new List<Wpt>();
    for (PointOfInterest poi in pointsOfInterest){
      wpts.add(new Wpt(
          lat: poi.latitude,
          lon: poi.longitude,
          name: "POI",
          desc: (poi.tags != null) ? new JsonEncoder.withIndent("  ").convert(poi.tags) : 'N/A'
      ));
    }

    return new Trk(
      name: "pois",
      desc: "contains pois of route",
      trksegs: [new Trkseg(trkpts: wpts)],
    );
  }

  //import part
  Future<HikingRoute> parseRouteFromString(String dataPath) async {
    File readSharedFile = await sharedFile(dataPath);
    String xmlString = await readSharedFile.readAsString();

    HikingRoute hikingRoute = _parseStringToRoute(xmlString);
    hikingRoute.totalLength = calculateDistance(hikingRoute.path);

    return hikingRoute;
  }

  HikingRoute _parseStringToRoute(String xmlString){
    Gpx gpxData = GpxReader().fromString(xmlString);

    List<Node> path = new List<Node>();
    List<double> elevations = new List<double>();
    for (Rte rte in gpxData.rtes){
      var idCounter = 0;

      rte.rtepts.forEach((wpt) {
        path.add(new Node(idCounter++, wpt.lat, wpt.lon));
        elevations.add(wpt.ele != null ? wpt.ele : 0);
      });
    }

    List<PointOfInterest> pointsOfInterest = new List();
    for (Trk trk in gpxData.trks){
      var idCounter = 0;

      trk.trksegs.forEach((trkSeg) => {
        trkSeg.trkpts.forEach((poiWpt) => pointsOfInterest.add(new PointOfInterest(idCounter++, poiWpt.lat, poiWpt.lon, json.decode(poiWpt.desc))))
      });
    }

    return new HikingRoute(path, 0, pointsOfInterest, elevations);
  }
}