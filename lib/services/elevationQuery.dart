import 'package:hiking4nerds/services/osmdata.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

class ElevationGetter {

  Future<List<double>> queryElevations(HikingRoute route) async {
    List<Node> path = route.path;
    List<double> queriedElevations = new List();
    String basisURL = "https://h4nsolo.f4.htw-berlin.de/elevation/api/v1/lookup?locations=";
    String currentURL = basisURL;
    int nodesPerQuery = 100; // they have to be devided because of the maximum URL character amount

    for (var i = 0; i < path.length; i++) {

      currentURL += path[i].latitude.toString() + "," + path[i].longitude.toString();

      if (i % nodesPerQuery == 0 && i > 0 || i == path.length - 1) { // every nodesPerQuery steps or when all paths were visisted
        var response = await http.get(currentURL);
        var parsedData = JSON.jsonDecode(response.body);
        int addRuns = (i % nodesPerQuery == 0) ? nodesPerQuery : i % nodesPerQuery;
        for (var j = 0; j <= addRuns; j++) {
          
          queriedElevations.add(parsedData["results"][j]["elevation"].toDouble());
        }
        currentURL = basisURL; // reset URL for next query
      } else {
        currentURL += "|"; // when there will follow a further node
      }
    }

    return queriedElevations;
  }
}
