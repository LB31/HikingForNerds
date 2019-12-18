import 'package:gpx/gpx.dart';
import 'package:hiking4nerds/services/osmdata.dart';
import 'package:hiking4nerds/services/route.dart';

class GpxExportHandler{

  /// parse List of Polyline objects to Gpx as String
  static String parseFromPolylines(List<Node> nodes){
    final gpx = Gpx();
    gpx.version = '1.1';
    gpx.creator = 'Hiking4Nerds';
    gpx.metadata = Metadata(
        name: 'Personal Route',
        desc: 'exported GPX Route',
        time: DateTime.now()
    );

    gpx.trks = new List<Trk>();
    gpx.trks.add(_getTrkList(nodes));

    return GpxWriter().asString(gpx, pretty: true);
  }

  static HikingRoute parseRouteFromString(String xmlGpxString){
    Gpx gpxData = GpxReader().fromString(xmlGpxString);

    List<Node> path = new List<Node>();
    for (Trk trk in gpxData.trks){
      int counter = 0;

      for (Trkseg trkseg in trk.trksegs){
        trkseg.trkpts.forEach((wpt) => path.add(new Node(counter++, wpt.lat, wpt.lon)));
      }
    }

    return new HikingRoute(path, null);
  }

  ///returns a Trk (Track) Object containing multiple trksegs (Tracksegments)
  ///one tracksegment containing multiple Waypoint objects
  static Trk _getTrkList(List<Node> nodes) {
    List<Wpt> wpts = new List<Wpt>();
    for (int i = 0; i < nodes.length; i++){
      wpts.add(new Wpt(
          lat: nodes[i].latitude,
          lon: nodes[i].longitude
      ));
    }

    Trkseg trksegs = new Trkseg(trkpts: wpts);

    return new Trk(
      name: "track",
      desc: "Track that contains a route",
      trksegs: [trksegs],
    );
  }
}