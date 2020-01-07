import 'dart:convert';
import 'dart:collection';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/edge.dart';
import 'package:hiking4nerds/services/routing/graph.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/routing/way.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';

class RouteThreadData {
  OsmData osmRef;
  double startLat;
  double startLong;
  double distanceInMeter;
  int alternativeRouteCount;
  List<dynamic> poiElements;
  List<HikingRoute> foundRoutes;
}

class OsmData{
  HashSet<Node> nodes;
  List<Way> ways;
  Graph graph;
  bool profiling = false;
  int _routeCalculationStartTime;
  Random _randomGenerator = Random(1);
  int maxRetries = 20;


  OsmData(){
    nodes = HashSet();
    ways = List();
  }

  void parseToObject(Map element){
    if(element['type'] == 'node'){
      nodes.add(Node(element['id'], element["lat"], element["lon"]));
    }
    if(element['type'] == 'way'){
      double wayPenalty;
      if(RegExp(r"motorway|trunk|primary|motorway_link|trunk_link|primary_link").hasMatch(element['tags']['highway'])) {
        wayPenalty = 20;
      }
      else if(RegExp(r"secondary|tertiary|secondary_link|tertiary_link").hasMatch(element['tags']['highway'])) {
        wayPenalty = 8;
      }
      else if(RegExp(r"cyclepath|track|path|bridleway|sidewalk|residential|service").hasMatch(element['tags']['highway'])) {
        wayPenalty = 2;
      }
      else if(RegExp(r"footway|pedestrian|unclassified").hasMatch(element['tags']['highway'])) {
        wayPenalty = 1;
      } else{
        wayPenalty = 5;
      }
      ways.add(Way(element['id'], element['nodes'].cast<int>(), this, wayPenalty));
    }
  }

  static double getDistance(LatLng nodeA, LatLng nodeB){
    //optimized haversine formular from https://stackoverflow.com/questions/27928/calculate-distance-between-two-latitude-longitude-points-haversine-formula
    var p = 0.017453292519943295;    // PI / 180
    var a = 0.5 - cos((nodeB.latitude - nodeA.latitude) * p)/2 + cos(nodeA.latitude* p) * cos(nodeB.latitude* p) * (1 - cos((nodeB.longitude - nodeA.longitude) * p))/2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // http://www.movable-type.co.uk/scripts/latlong.html
  static double getBearing(Node nodeA, Node nodeB){
    var lat1 = _toRadians(nodeA.latitude);
    var lat2 = _toRadians(nodeB.latitude);
    var lon1 = _toRadians(nodeA.longitude);
    var lon2 = _toRadians(nodeB.longitude);
    var y = sin(lon2 - lon1) * cos(lat2);
    var x = cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(lon2-lon1);
    var rad = atan2(y, x);
    return (_toDegrees(rad) + 360) % 360;
  }

  void buildGraph(){
    graph = Graph();
    Map<Node, int> nodeCount= Map();
    for(Way way in ways) {
      for (Node node in way.childNodes) {
        nodeCount.putIfAbsent(node, () => 0);
        nodeCount[node]++;
      }
    }
    for(Way way in ways){
      var lastIntersection = way.childNodes.first;
      var lastNode = way.childNodes.first;
      double currentLength = 0;
      for(Node node in way.childNodes){
        currentLength += getDistance(lastNode, node);
        lastNode = node;
        if(nodeCount[node] > 1 && node != lastIntersection){
          graph.addEdge(lastIntersection, node, currentLength, way);
          currentLength = 0;
          lastIntersection = node;
        }
        else if(node == way.childNodes.last){
          graph.addEdge(lastIntersection, node, currentLength, way);
        }
      }
    }
  }

  static double _toRadians(double angleInDeg){
    return (angleInDeg*pi)/180.0;
  }
  static double _toDegrees(double angleInRad){
    return (angleInRad*180.0)/pi;
  }

  List<double> projectCoordinate(double latInDeg, double longInDeg, double distanceInM, double headingFromNorth){
    var latInRadians = _toRadians(latInDeg);
    var longInRadians = _toRadians(longInDeg);
    var headingInRadians = _toRadians(headingFromNorth);

    double angularDistance = distanceInM / 6371000.0;

    // This formula is taken from: http://williams.best.vwh.net/avform.htm#LL
    // (http://www.movable-type.co.uk/scripts/latlong.html -> https://github.com/chrisveness/geodesy  ->  https://github.com/graphhopper/graphhopper Apache 2.0)
    // θ=heading,δ=distance,φ1=latInRadians
    // lat2 = asin( sin φ1 ⋅ cos δ + cos φ1 ⋅ sin δ ⋅ cos θ )
    // lon2 = λ1 + atan2( sin θ ⋅ sin δ ⋅ cos φ1, cos δ − sin φ1 ⋅ sin φ2 )
    double projectedLat = asin(sin(latInRadians) * cos(angularDistance)
        + cos(latInRadians) * sin(angularDistance) * cos(headingInRadians));
    double projectedLon = longInRadians + atan2(sin(headingInRadians) * sin(angularDistance) * cos(latInRadians),
        cos(angularDistance) - sin(latInRadians) * sin(projectedLat));

    projectedLon = (projectedLon + 3 * pi) % (2 * pi) - pi; // normalise to -180..+180°

    projectedLat = projectedLat * 180/pi;
    projectedLon = projectedLon * 180/pi;

    return [projectedLat, projectedLon];
  }


  Node getClosestToPoint(double latitude, double longitude){
    var pointDummy = LatLng(latitude, longitude);
    var closestPoint = graph.adjacencies.keys.reduce((curr, next) => getDistance(pointDummy, curr) < getDistance(pointDummy, next) ? curr:next);
    return closestPoint;
  }

  static HikingRoute doRouteCalculationsThreaded(RouteThreadData data) {
    var usePOIFunc = data.poiElements != null;
    var alternativeRouteCount = data.alternativeRouteCount;
    var startLat = data.startLat;
    var startLong = data.startLong;
    var distanceInMeter = data.distanceInMeter;
    var poiElements = data.poiElements;

    var retryCount = 0;
    while(retryCount < data.osmRef.maxRetries) {
      if(usePOIFunc)
      {
        try {
          return data.osmRef._calculateHikingRoutesWithPois(alternativeRouteCount, startLat, startLong, distanceInMeter, poiElements, retryCount);
        }
        on NoRoutesFoundException catch(e) {
          retryCount++;
        }
      }
      else
      {
        try {
          return data.osmRef._calculateHikingRoutesWithoutPois(alternativeRouteCount, startLat, startLong, distanceInMeter);
        }
        on NoRoutesFoundException catch(e) {
          retryCount++;
        }
      }
    }
    throw NoRoutesFoundException;
  }

  Future<List<HikingRoute>> calculateHikingRoutes(double startLat, double startLong, double distanceInMeter, [int alternativeRouteCount = 1, String poiCategory='']) async{
    if(profiling) _routeCalculationStartTime = DateTime.now().millisecondsSinceEpoch;

    List<dynamic> poiElements;
    if(poiCategory.isNotEmpty){
      var jsonDecoder = JsonDecoder();
      var poisJson = await _getPoisJSON(poiCategory, startLat, startLong, distanceInMeter/2);
      if(profiling) print("POI OSM Query done after " + (DateTime.now().millisecondsSinceEpoch - _routeCalculationStartTime).toString() + " ms");
      poiElements = jsonDecoder.convert(poisJson)['elements'];
      if(poiElements.isEmpty){
        throw NoPOIsFoundException;
      }
    }

    var jsonNodesAndWays = await getWaysJson(startLat, startLong, distanceInMeter/2);
    if(profiling) print("OSM Query done after " + (DateTime.now().millisecondsSinceEpoch - _routeCalculationStartTime).toString() + " ms");
    _importJsonNodesAndWays(jsonNodesAndWays);

    List<HikingRoute> routes = List();

    RouteThreadData data = RouteThreadData();
    data.alternativeRouteCount = alternativeRouteCount;
    data.distanceInMeter = distanceInMeter;
    data.foundRoutes = List();
    data.startLat = startLat;
    data.startLong = startLong;
    data.osmRef = this;
    data.poiElements = poiElements;

    List<Future<HikingRoute>> computeFutures = List();
    for(int i = 0; i < alternativeRouteCount; ++i) {
        computeFutures.add(compute(doRouteCalculationsThreaded, data));
    }
    if(profiling) print("Routing Algorithm done after " + (DateTime.now().millisecondsSinceEpoch - _routeCalculationStartTime).toString() + " ms");
    return Future.wait(computeFutures);
  }

  HikingRoute _calculateHikingRoutesWithoutPois(int alternativeRouteCount, double startLat, double startLong, double distanceInMeter) {
    var initialHeading = _randomGenerator.nextInt(360).floorToDouble();
    var pointB = projectCoordinate(startLat, startLong, distanceInMeter/3, initialHeading);
    var pointC = projectCoordinate(startLat, startLong, distanceInMeter/3, initialHeading + 60);

    var nodeA = getClosestToPoint(startLat, startLong);
    var nodeB = getClosestToPoint(pointB[0], pointB[1]);
    var nodeC = getClosestToPoint(pointC[0], pointC[1]);

    var aToB = graph.AStar(nodeA, nodeB);
    if(aToB.isNotPresent){
      throw NoRoutesFoundException;
    }
    graph.penalizeEdgesAlongRoute(aToB.value, 2);
    var bToC = graph.AStar(nodeB, nodeC);
    if(bToC.isNotPresent){
      throw NoRoutesFoundException;
    }
    graph.penalizeEdgesAlongRoute(bToC.value, 2);
    var cToA = graph.AStar(nodeC, nodeA);
    if(aToB.isNotPresent){
      throw NoRoutesFoundException;
    }
    graph.penalizeEdgesAlongRoute(cToA.value, 2);

    var routeAlternative = aToB.value;
    routeAlternative.addAll(bToC.value);
    routeAlternative.addAll(cToA.value);

    var routeAlternativeNodes = List<Node>();
    routeAlternative.forEach((edge) => routeAlternativeNodes.addAll(graph.edgeToNodes(edge)));
    var route = (HikingRoute(routeAlternativeNodes, lengthOfEdgesKM(routeAlternative)));
    if(profiling) print("Route " + (route).toString() + " done after " + (DateTime.now().millisecondsSinceEpoch - _routeCalculationStartTime).toString() + " ms");

    return route;
  }

  HikingRoute _calculateHikingRoutesWithPois(int alternativeRouteCount, double startLat, double startLong, double distanceInMeter, List<dynamic> poiElements, int retryCount) {
    List<HikingRoute> routes = List();var startNode = getClosestToPoint(startLat, startLong);

    var pointsOfInterests = poiElements.map((element) => PointOfInterest(element['id'], element['lat'], element['lon'], element['tags'])).toList();
    pointsOfInterests.sort((a,b) => getDistance(startNode, a).compareTo(getDistance(startNode, b)));
    var closestPointsOfInterests = pointsOfInterests.sublist(0,min( pointsOfInterests.length, 50));
    Map<Node, PointOfInterest> wayNodeAndPOI = Map.fromIterable(closestPointsOfInterests,
        value: (cPoi) => cPoi,
        key: (cPoi) => getClosestToPoint(cPoi.latitude, cPoi.longitude));
    if(profiling) print("Nodes to " + wayNodeAndPOI.length.toString() + " POIs found after " + (DateTime.now().millisecondsSinceEpoch - _routeCalculationStartTime).toString() + " ms");
    List<PointOfInterest> includedPois = List();
    List<Edge> route = List();
    var wayNodeAndPOICopy = Map.from(wayNodeAndPOI);
    var lastVisited = startNode;
    var totalRouteLength = 0.0;
    //determine first poi to go to
    var unsortedPoiNodeList = wayNodeAndPOICopy.keys.toList();
    unsortedPoiNodeList.sort((a,b) => getDistance(startNode, a).compareTo(getDistance(startNode, b)));
    var firstPoi = unsortedPoiNodeList[(routes.length + retryCount) % unsortedPoiNodeList.length];
    //plan route to that poi
    var routeToFirstPoi = graph.AStar(lastVisited, firstPoi);
    if(routeToFirstPoi.isNotPresent){
      throw NoRoutesFoundException;
    }
    totalRouteLength += lengthOfEdgesKM(routeToFirstPoi.value);
    route.addAll(routeToFirstPoi.value);
    graph.penalizeEdgesAlongRoute(routeToFirstPoi.value, 5);
    includedPois.add(wayNodeAndPOICopy[firstPoi]);
    wayNodeAndPOICopy.remove(firstPoi);
    lastVisited = firstPoi;
    //start loop over all the other pois
    while(wayNodeAndPOICopy.isNotEmpty && (getDistance(startNode, lastVisited) + totalRouteLength) < distanceInMeter / 1000){
      var closestPoiWayNode = wayNodeAndPOICopy.keys.reduce((curr, next) => getDistance(lastVisited, curr) < getDistance(lastVisited, next) ? curr : next);
      var routeToClosestPoi = graph.AStar(lastVisited, closestPoiWayNode);
      if(routeToClosestPoi.isNotPresent){
        wayNodeAndPOICopy.remove(closestPoiWayNode);
        continue;
      }
      totalRouteLength += lengthOfEdgesKM(routeToClosestPoi.value);
      route.addAll(routeToClosestPoi.value);
      graph.penalizeEdgesAlongRoute(routeToClosestPoi.value, 5);
      includedPois.add(wayNodeAndPOICopy[closestPoiWayNode]);
      wayNodeAndPOICopy.remove(closestPoiWayNode);
      lastVisited = closestPoiWayNode;
    }

    List<Edge> routeBack = List();
    if(wayNodeAndPOICopy.isEmpty){ //route is probably not long enough yet
      var slightDistanceModifier = 1.0;
      while(retryCount <= maxRetries){
        var a = (((distanceInMeter/1000) - totalRouteLength) /2) * slightDistanceModifier;
        var b = (((distanceInMeter/1000) - totalRouteLength) /2) * slightDistanceModifier;
        var c = getDistance(startNode, lastVisited);
        var cosGamma = (a*a+b*b-c*c)/(2*a*b);
        var relativeGamma = _toDegrees(acos(cosGamma));
        var relativeAlpha = (180-relativeGamma)/2;
        var absoluteAlpha = (getBearing(lastVisited, startNode) + relativeAlpha) % 360; //this is so me
        var makeRouteLongEnoughPoint = projectCoordinate(lastVisited.latitude, lastVisited.longitude, b * 1000, absoluteAlpha);
        var routeExtensionNode = getClosestToPoint(makeRouteLongEnoughPoint[0], makeRouteLongEnoughPoint[1]);
        var routeToExtensionNode = graph.AStar(lastVisited, routeExtensionNode);
        var routeFromExtensionNode = graph.AStar(routeExtensionNode, startNode);
        if(routeToExtensionNode.isNotPresent || routeFromExtensionNode.isNotPresent){
          print("Warning: path to routeExtensionNode (" + routeExtensionNode.id.toString() + ") not found, retrying... retry count: " + retryCount.toString());
          retryCount ++;
          slightDistanceModifier = (12 - _randomGenerator.nextDouble() * 4)/10.0;
          continue;
        }else{
          routeBack.addAll(routeToExtensionNode.value);
          routeBack.addAll(routeFromExtensionNode.value);
          break;
        }
      }
    }else{ //route is already long enough, just go back
      var routeBackOptional = graph.AStar(lastVisited, startNode);
      if(routeBackOptional.isNotPresent){
        throw NoRoutesFoundException;
      }
      routeBack.addAll(routeBackOptional.value);
    }
    graph.penalizeEdgesAlongRoute(routeBack, 5);
    totalRouteLength += lengthOfEdgesKM(routeBack) ;
    route.addAll(routeBack);
    List<Node> routeNodes = List();
    route.forEach((edge) => routeNodes.addAll(graph.edgeToNodes(edge)));
    var hikRoute = HikingRoute(routeNodes, totalRouteLength, includedPois);
    if(profiling) print("Route " + (route.length).toString() + " done after " + (DateTime.now().millisecondsSinceEpoch - _routeCalculationStartTime).toString() + " ms");
    return hikRoute;
  }

  double lengthOfEdgesKM(List<Edge> edges){
    return edges.map((edge) => edge.weight).fold(0.0, (curr, next) => curr + next);
  }

  void _importJsonNodesAndWays(String jsonNodesAndWays){
    var jsonDecoder = JsonDecoder();
    dynamic parsedData = jsonDecoder.convert(jsonNodesAndWays)['elements'];
    parsedData.forEach((element) => parseToObject(element));
    if(profiling) print("OSM JSON parsed after " + (DateTime.now().millisecondsSinceEpoch - _routeCalculationStartTime).toString() + " ms");
    buildGraph();
    if(profiling) print("Graph built after " + (DateTime.now().millisecondsSinceEpoch - _routeCalculationStartTime).toString() + " ms");
  }

  Future<String> _getPoisJSON(String category, aroundLat, aroundLong, radius) async{
    var topLeftBoundingBox = projectCoordinate(aroundLat, aroundLong, radius * 1.41, 315);
    var northernBorder = topLeftBoundingBox[0];
    var westernBorder = topLeftBoundingBox[1];
    var bottomRightBoundingBox = projectCoordinate(aroundLat, aroundLong, radius * 1.41, 135);
    var southernBorder = bottomRightBoundingBox[0];
    var easternBorder = bottomRightBoundingBox[1];

    var url = 'http://overpass-api.de/api/interpreter?data=[bbox:$southernBorder, $westernBorder, $northernBorder, $easternBorder]'
        '[out:json][timeout:300]'
        ';node["tourism"="$category"](around:$radius,$aroundLat, $aroundLong);'
        'out body qt;';

    var response = await http.get(url);
    if(response.statusCode != 200) print("OSM POI request failed. Statuscode:" + response.statusCode.toString() +
        "\n Query: " + url +
        "\n Message: " + response.body);
    return response.body;
  }

   Future<String> getWaysJson(double aroundLat, double aroundLong, radius) async {
    var topLeftBoundingBox = projectCoordinate(aroundLat, aroundLong, radius * 1.41, 315);
    var northernBorder = topLeftBoundingBox[0];
    var westernBorder = topLeftBoundingBox[1];
    var bottomRightBoundingBox = projectCoordinate(aroundLat, aroundLong, radius * 1.41, 135);
    var southernBorder = bottomRightBoundingBox[0];
    var easternBorder = bottomRightBoundingBox[1];

    var url = 'http://overpass-api.de/api/interpreter?data=[bbox:$southernBorder, $westernBorder, $northernBorder, $easternBorder]'
        '[out:json][timeout:300]'
        ';way["highway"](around:$radius,$aroundLat, $aroundLong);'
        '(._;>;); out body qt;';

    var response = await http.get(url);
    if(response.statusCode != 200) print("OSM request failed. Statuscode:" + response.statusCode.toString() +
        "\n Query: " + url +
        "\n Message: " + response.body);
    return response.body;
  }
}

class NoPOIsFoundException {
  @override
  String toString() {
    return "No points of interest found to given categories.";
  }
}

class NoRoutesFoundException implements Exception{
  @override
  String toString() {
    return "No routes found to given parameters.";
  }
}

void main() async {
  var osmData = OsmData();
  osmData.profiling = true;
  var route = await osmData.calculateHikingRoutes(
      52.510143, 13.408564, 10000, 10, "aquarium");
  print(route.length);
}
