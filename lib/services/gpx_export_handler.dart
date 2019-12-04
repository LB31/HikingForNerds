import 'package:flutter_map/flutter_map.dart';
import 'package:gpx/gpx.dart';

class GpxExportHandler{

  /// parse List of Polyline objects to Gpx as String
  static String parseFromPolylines(List<Polyline> polylines){
    final gpx = Gpx();
    gpx.version = '1.1';
    gpx.creator = 'Hiking4Nerds';
    gpx.metadata = Metadata(
        name: 'Personal Route',
        desc: 'exported GPX Route',
        time: DateTime.now()
    );

    gpx.trks = new List<Trk>();
    for(Polyline polyline in polylines){
      gpx.trks.add(_getTrkList(polyline));
    }

    return GpxWriter().asString(gpx, pretty: true);
  }

  ///returns a Trk (Track) Object containing multiple trksegs (Tracksegments)
  ///one tracksegment containing multiple Waypoint objects
  static Trk _getTrkList(Polyline polyline) {
    List<Wpt> wpts = new List<Wpt>();
    for (int i = 0; i < polyline.points.length; i++){
      wpts.add(new Wpt(
          lat: polyline.points[i].latitude,
          lon: polyline.points[i].longitude
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