import 'package:gpx/gpx.dart';
import 'package:hiking4nerds/services/routing/node.dart';

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