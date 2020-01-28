import 'dart:convert';
import 'dart:collection';
import 'dart:math';
import 'dart:async';
import 'package:collection/priority_queue.dart';
import 'package:flutter/cupertino.dart';
import 'package:hiking4nerds/services/elevation_query.dart';
import 'package:hiking4nerds/services/routing/geo_utilities.dart';
import 'package:quiver/core.dart';
import 'package:flutter/foundation.dart';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/edge.dart';
import 'package:hiking4nerds/services/routing/graph.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/routing/way.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';
import '../localization_service.dart';


class RouteThreadData {
  OsmData osmRef;
  double startLat;
  double startLong;
  double distanceInMeter;
  int alternativeRouteCount;
  List<dynamic> poiElements;
  List<String> poiCategories;
  List<HikingRoute> foundRoutes;
}


class PoiRouteTriplet{
  List<PointOfInterest> pois;
  double estimatedRouteLength;
  PoiRouteTriplet(){
    pois = List();
  }

  @override
  bool operator ==(other) => other is PoiRouteTriplet && other.pois[0] == pois[0] && other.pois[1] == pois[1]&& other.pois[2] == pois[2];

  @override
  int get hashCode => hash3(pois[0].hashCode, pois[1].hashCode, pois[2].hashCode);
}

List<HikingRoute> _doRouteCalculationsThreaded(RouteThreadData data) {
  var usePOIFunc = data.poiElements != null;
  var startLat = data.startLat;
  var startLong = data.startLong;
  var distanceInMeter = data.distanceInMeter;
  var poiElements = data.poiElements;
  var poiCategories = data.poiCategories;
  var osm = data.osmRef;
  var alternativeRouteCount = data.alternativeRouteCount;

  try {
    if(usePOIFunc) {
      return osm._calculateHikingRoutesWithPois(alternativeRouteCount, startLat, startLong, distanceInMeter, poiElements, poiCategories);
    }
    else {
      return osm._calculateHikingRoutesWithoutPois(alternativeRouteCount, startLat, startLong, distanceInMeter);
    }
  }
  catch(_) {
    return List();
  }
}

Graph _buildGraphThreaded(String nodesAndWaysJSON) {
  return Graph(nodesAndWaysJSON);
}

class OsmData{
  Graph graph;
  int _routeCalculationStartTime;
  Random _randomGenerator = Random(1);
  int maxRetries = 10;
  double beeLineToRealRatio = 0.7; // estimate of how much the beeline distance differs from real path distance
  double beeLineToRealRatioWithPOI = 0.6; // estimate of how much the beeline distance differs from real path distance
  static const bool PROFILING = true;

  Future<List<HikingRoute>> calculateHikingRoutes(double startLat, double startLong, double distanceInMeter, [int alternativeRouteCount = 1, List<String> poiCategories]) async{
    if(PROFILING) _routeCalculationStartTime = DateTime.now().millisecondsSinceEpoch;

    List<dynamic> poiElements;
    if (poiCategories != null && poiCategories.isNotEmpty) {
      var jsonDecoder = JsonDecoder();
      var poisJson = await _queryPOIs(poiCategories, startLat, startLong, distanceInMeter/3.0);
      poiElements = jsonDecoder.convert(poisJson)['elements'];
      if(poiElements.isEmpty){
        throw new NoPOIsFoundException();
      }
    }

    var jsonNodesAndWays = await _queryNodesAndWays(startLat, startLong, distanceInMeter/2.0);

    graph = await compute(_buildGraphThreaded, jsonNodesAndWays);

    RouteThreadData data = RouteThreadData();
    data.distanceInMeter = distanceInMeter;
    data.foundRoutes = List();
    data.startLat = startLat;
    data.startLong = startLong;
    data.alternativeRouteCount = alternativeRouteCount;
    data.osmRef = this;
    data.poiCategories = poiCategories;
    data.poiElements = poiElements;


    List<HikingRoute> routes = await compute(_doRouteCalculationsThreaded, data);

    var elevationTimestamp = DateTime.now().millisecondsSinceEpoch;
    for(var route in routes){
      route.elevations = await ElevationQuery.queryElevations(route);
    }
    if(PROFILING){
      print("Elevation Queried in " + (DateTime.now().millisecondsSinceEpoch - elevationTimestamp).toString() + " ms");
      print("Routing done in " + (DateTime.now().millisecondsSinceEpoch - _routeCalculationStartTime).toString() + " ms");

    }
    return routes;
  }

  List<HikingRoute> _calculateHikingRoutesWithoutPois(int alternativeRouteCount, double startLat, double startLong, double targetActualDistance) {
    //algorithm is using beelinedistance for creating the roundtrip. That bee line distance has to be shorter since real paths are always longer than beeline distance
    var beeLineDistance = targetActualDistance * beeLineToRealRatio; List<HikingRoute> routes = List();
    var retryCount = 0;
    while(routes.length < alternativeRouteCount && retryCount <= maxRetries){
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      graph.edgeAlreadyUsedPenalties.clear();
      var initialHeading = _randomGenerator.nextInt(360).floorToDouble();
      var pointB = projectCoordinate(startLat, startLong, beeLineDistance/3, initialHeading);
      var pointC = projectCoordinate(startLat, startLong, beeLineDistance/3, initialHeading + 60);

      var nodeA = graph.getClosestNodeToCoordinates(startLat, startLong);
      var nodeB = graph.getClosestNodeToCoordinates(pointB[0], pointB[1]);
      var nodeC = graph.getClosestNodeToCoordinates(pointC[0], pointC[1]);

      var aToB = graph.AStar(nodeA, nodeB);
      if(aToB.isNotPresent){
        print("Warning: path to B not found, retrying... retry count: " + retryCount.toString());
        retryCount++;
        continue;
      }
      graph.penalizeEdgesAlongRoute(aToB.value, 2);
      var bToC = graph.AStar(nodeB, nodeC);
      if(bToC.isNotPresent){
        print("Warning: path to C not found, retrying... retry count: " + retryCount.toString());
        retryCount++;
        continue;
      }
      graph.penalizeEdgesAlongRoute(bToC.value, 2);
      var cToA = graph.AStar(nodeC, nodeA);
      if(aToB.isNotPresent){
        print("Warning: path to C not found, retrying... retry count: " + retryCount.toString());
        retryCount++;
        continue;
      }
      graph.penalizeEdgesAlongRoute(cToA.value, 2);

      var routeAlternative = aToB.value;
      routeAlternative.addAll(bToC.value);
      routeAlternative.addAll(cToA.value);

      var routeAlternativeNodes = List<Node>();
      routeAlternative.forEach((edge) => routeAlternativeNodes.addAll(graph.edgeToNodes(edge)));
      var resultRoute = HikingRoute(routeAlternativeNodes, graph.lengthOfEdgesKM(routeAlternative));
      if (resultRoute.totalLength < targetActualDistance * 0.8 || resultRoute.totalLength > targetActualDistance * 1.2){
        retryCount ++;
        if(PROFILING) print("Route too long or to short (" + resultRoute.totalLength.toString() + ") , retrying...");
        continue;
      }
      routes.add(resultRoute);
      if(PROFILING) print("Route " + (routes.length).toString() + " done in " + (DateTime.now().millisecondsSinceEpoch - timestamp).toString() + " ms. Total length: " + resultRoute.totalLength.toString());
    }
    if(routes.length == 0){
      throw NoRoutesFoundException;
    }
    return routes;
  }

  List<HikingRoute> _calculateHikingRoutesWithPois(int alternativeRouteCount, double startLat, double startLong, double targetActualDistance, List<dynamic> poiElements, List<String> poiCategories) {
    var timestampCalculationStart = DateTime.now().millisecondsSinceEpoch;
    var pointsOfInterest = poiElements.map((element) => PointOfInterest(element['id'], element['lat'], element['lon'], element['tags'])).toList();
    var timestampPoisParsed = DateTime.now().millisecondsSinceEpoch;
    if(PROFILING) print(pointsOfInterest.length.toString() + " POIs parsed in " + (DateTime.now().millisecondsSinceEpoch - timestampCalculationStart).toString() + " ms");

    List<HikingRoute> routes = List();
    double targetBeelineDistance = targetActualDistance * beeLineToRealRatioWithPOI;
    var startNode = graph.getClosestNodeToCoordinates(startLat, startLong);
    pointsOfInterest.shuffle(_randomGenerator);
    PriorityQueue<PoiRouteTriplet> bestTriplets = PriorityQueue((routePoiTripletA, routePoiTripletB) => ((targetBeelineDistance - routePoiTripletA.estimatedRouteLength).abs())
        .compareTo((targetBeelineDistance - routePoiTripletB.estimatedRouteLength).abs()));
    for(var poi in pointsOfInterest.where((element) => element.getCategoryString() == poiCategories[0]).take(100)){
      for(var poi2 in pointsOfInterest.where((element) => element.getCategoryString() == poiCategories[1%poiCategories.length]).take(100)){
        for(var poi3 in pointsOfInterest.where((element) => element.getCategoryString() == poiCategories[2%poiCategories.length]).take(100)){
            Set<PointOfInterest> tripletCandidates = new Set();
            tripletCandidates.addAll([poi, poi2, poi3]);
            if(tripletCandidates.length != 3) continue;
            var closestToStart = tripletCandidates.reduce((poiA, poiB) => getDistance(startNode, poiA) < getDistance(startNode, poiB) ? poiA : poiB );
            tripletCandidates.remove(closestToStart);
            var nextPoi = tripletCandidates.reduce((poiA, poiB) => getDistance(closestToStart, poiA) < getDistance(closestToStart, poiB) ? poiA : poiB );
            tripletCandidates.remove(nextPoi);
            var lastPoi = tripletCandidates.first;
            var triplet = PoiRouteTriplet();
            triplet.pois.addAll([closestToStart, nextPoi, lastPoi]);
            triplet.estimatedRouteLength = getDistance(startNode, closestToStart) + getDistance(closestToStart, nextPoi) + getDistance(nextPoi, lastPoi) + getDistance(lastPoi, startNode);

            bestTriplets.add(triplet);
          }
        }
      }
    if(PROFILING) print(bestTriplets.length.toString() + " triplets built in: " + (DateTime.now().millisecondsSinceEpoch - timestampPoisParsed).toString() + " ms");

    var retryCount = 0;
    Set<PoiRouteTriplet> alreadyUsedTriplets = Set();
    while(routes.length < alternativeRouteCount && retryCount < maxRetries){
      var timestampRouteStart = DateTime.now().millisecondsSinceEpoch;
      var nextTriplet = bestTriplets.removeFirst();
      List<PointOfInterest> nextPois;
      if(!alreadyUsedTriplets.contains(nextTriplet)){
        alreadyUsedTriplets.add(nextTriplet);
        nextPois = nextTriplet.pois;
      }
      else{
        continue;
      }
      Map<Node, PointOfInterest> wayNodeAndPOI = Map.fromIterable(nextPois,
          value: (cPoi) => cPoi,
          key: (cPoi) => graph.getClosestNodeToCoordinates(cPoi.latitude, cPoi.longitude));
      graph.edgeAlreadyUsedPenalties.clear();
      List<PointOfInterest> includedPois = List();
      List<Edge> route = List();
      var wayNodeAndPOICopy = Map.from(wayNodeAndPOI);
      var lastVisited = startNode;
      var totalRouteLength = 0.0;

      //start loop over all the other pois
      while(wayNodeAndPOICopy.isNotEmpty && (getDistance(startNode, lastVisited) * (1/beeLineToRealRatioWithPOI) + totalRouteLength) < targetActualDistance ){
        var closestPoiWayNode = wayNodeAndPOICopy.keys.reduce((curr, next) => getDistance(lastVisited, curr) < getDistance(lastVisited, next) ? curr : next);
        var routeToClosestPoi = graph.AStar(lastVisited, closestPoiWayNode);
        if(routeToClosestPoi.isNotPresent){
          wayNodeAndPOICopy.remove(closestPoiWayNode);
          continue;
        }
        totalRouteLength += graph.lengthOfEdgesKM(routeToClosestPoi.value);
        route.addAll(routeToClosestPoi.value);
        graph.penalizeEdgesAlongRoute(routeToClosestPoi.value, 5);
        includedPois.add(wayNodeAndPOICopy[closestPoiWayNode]);
        wayNodeAndPOICopy.remove(closestPoiWayNode);
        lastVisited = closestPoiWayNode;
      }

      List<Edge> routeBack = List();
      if(wayNodeAndPOICopy.isEmpty && (targetActualDistance - totalRouteLength) > getDistance(startNode, lastVisited)/beeLineToRealRatioWithPOI ){ //route is probably not long enough yet
        var slightDistanceModifier = 1.0;
        while(retryCount <= maxRetries){
          var a = ((targetActualDistance - totalRouteLength) * beeLineToRealRatioWithPOI /2) * slightDistanceModifier;
          var b = ((targetActualDistance- totalRouteLength)  * beeLineToRealRatioWithPOI /2) * slightDistanceModifier;
          var c = getDistance(startNode, lastVisited);
          var cosGamma = (a*a+b*b-c*c)/(2*a*b);
          var relativeGamma = toDegrees(acos(cosGamma));
          var relativeAlpha = (180-relativeGamma)/2;
          if (relativeAlpha.isNaN){ //this can happen when (a + b) < c, in this case, the direct route should be taken, so the angle can be 0
            relativeAlpha = 0;
          }
          var absoluteAlpha = (getBearing(lastVisited, startNode) + relativeAlpha) % 360; //this is so me
          var makeRouteLongEnoughPoint = projectCoordinate(lastVisited.latitude, lastVisited.longitude, b, absoluteAlpha);
          var routeExtensionNode = graph.getClosestNodeToCoordinates(makeRouteLongEnoughPoint[0], makeRouteLongEnoughPoint[1]);
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
          print("Warning: path returning to startPoint not found, retrying... retry count: " + retryCount.toString());
          retryCount ++;
          continue;
        }
        routeBack.addAll(routeBackOptional.value);
      }
      graph.penalizeEdgesAlongRoute(routeBack, 5);
      totalRouteLength += graph.lengthOfEdgesKM(routeBack) ;
      route.addAll(routeBack);
      List<Node> routeNodes = List();
      route.forEach((edge) => routeNodes.addAll(graph.edgeToNodes(edge)));
      var routeResult = HikingRoute(routeNodes, totalRouteLength, includedPois);
      if(routeResult.totalLength < targetActualDistance * 0.8 || routeResult.totalLength > targetActualDistance * 1.2){
        retryCount ++;
        if(PROFILING) print("Route too long or to short (" + totalRouteLength.toString() + ") , retrying... retry count: " + retryCount.toString());
        continue;
      }
      routes.add(routeResult);
      if(PROFILING) print("Route " + (routes.length).toString() + " done in " + (DateTime.now().millisecondsSinceEpoch - timestampRouteStart).toString()
          + " ms. Total length: " + routeResult.totalLength.toString() + ". Nr of POI: " + routeResult.pointsOfInterest.length.toString());
    }
    if(routes.length == 0) {
      throw NoRoutesFoundException;
    }
    return routes;
  }


  Future<String> _queryPOIs(List<String> categories, aroundLat, aroundLong, radius) async{
    var topLeftBoundingBox = projectCoordinate(aroundLat, aroundLong, radius * 1.41, 315);
    var northernBorder = topLeftBoundingBox[0];
    var westernBorder = topLeftBoundingBox[1];
    var bottomRightBoundingBox = projectCoordinate(aroundLat, aroundLong, radius * 1.41, 135);
    var southernBorder = bottomRightBoundingBox[0];
    var easternBorder = bottomRightBoundingBox[1];
    var categoryString = categories.join('|');
    var radiusInM = radius*1000;
    var url = 'https://overpass.kumi.systems/api/interpreter?data=[bbox:$southernBorder, $westernBorder, $northernBorder, $easternBorder]'
        '[out:json][timeout:300];'
        '(node["tourism"~"$categoryString"](around:$radiusInM,$aroundLat, $aroundLong);'
        'node["amenity"~"$categoryString"](around:$radiusInM,$aroundLat, $aroundLong););'
        'out body qt;';

    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var response = await http.get(url);
    if(PROFILING) print("POI query done in " + (DateTime.now().millisecondsSinceEpoch - timestamp).toString() + " ms");

    if(response.statusCode != 200) print("OSM POI request failed. Statuscode:" + response.statusCode.toString() +
        "\n Query: " + url +
        "\n Message: " + response.body);
    return response.body;
  }

  Future<String> _queryNodesAndWays(double aroundLat, double aroundLong, radius) async {
    var topLeftBoundingBox = projectCoordinate(aroundLat, aroundLong, radius * 1.41, 315);
    var northernBorder = topLeftBoundingBox[0];
    var westernBorder = topLeftBoundingBox[1];
    var bottomRightBoundingBox = projectCoordinate(aroundLat, aroundLong, radius * 1.41, 135);
    var southernBorder = bottomRightBoundingBox[0];
    var easternBorder = bottomRightBoundingBox[1];
    var radiusInM = radius*1000;

    var url = 'https://overpass.kumi.systems/api/interpreter?data=[bbox:$southernBorder, $westernBorder, $northernBorder, $easternBorder]'
        '[out:json][timeout:300]'
        ';way["highway"](around:$radiusInM,$aroundLat, $aroundLong);'
        '(._;>;); out body qt;';
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var response = await http.get(url);
    if(PROFILING) print("Map query done in " + (DateTime.now().millisecondsSinceEpoch - timestamp).toString() + " ms");
    if(response.statusCode != 200) print("OSM request failed. Statuscode:" + response.statusCode.toString() +
        "\n Query: " + url +
        "\n Message: " + response.body);
    return response.body;
  }
}

class NoPOIsFoundException implements Exception {
  @override
  String toString() {
    return LocalizationService().getLocalization(english: "No points of interest found to given categories.", german: "Für die gewählten Kategorien wurden keine Sehenswürdigkeiten gefunden");
  }
}

class NoRoutesFoundException implements Exception{
  @override
  String toString() {
    return LocalizationService().getLocalization(english: "No routes found to given parameters.", german: "Für die gewählten Parameter wurden keine Routen gefunden");
  }
}

