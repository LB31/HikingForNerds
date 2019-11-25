import 'dart:convert';
import 'dart:collection';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:r_tree/r_tree.dart' as rtree;

class Node{
  int _id;
  int get id => _id;
  double _latitude;
  double get latitude => _latitude;
  double _longitude;
  double get longitude => _longitude;

  Node(this._id, this._latitude, this._longitude);

  @override
  bool operator ==(other) => other is Node && other.id ==id;

  @override
  int get hashCode => id;

  @override
  String toString() => "id: $id, lat: $latitude, lng: $longitude";
}

class Way{
  int _id;
  int get id => _id;
  double initialPenalty;
  List<Node> childNodes;
  Way(this._id, List<int> nodeIds, OsmData dataWithNodes, this.initialPenalty){
    childNodes = List();
    for(int nodeId in nodeIds){
      //adds the actual node object to the way instead of only the node id. Lookup returns the object found in the set,
      //so with an overridden equals method we can get the wanted node by passing that function a dummy node with the required id.
      childNodes.add(dataWithNodes.nodes.lookup(Node(nodeId, 0.0, 0.0)));
    }
  }
}

class Edge{
  Node nodeFrom;
  Node nodeTo;
  double weight;
  Way parentWay;
  Edge back;

  Edge(this.nodeFrom, this.nodeTo, this.weight, this.parentWay);
}

class Graph {
  Map<Node, List<Edge>> adjacencies;
  Map<Edge, double> penalties; //factor that penalizes edges, for example when they were used already in a roundtrip

  Graph() {
    adjacencies = Map();
    penalties = Map();
  }

  void addEdge(Node nodeA, Node nodeB, double weight, Way parentWay) {
    adjacencies.putIfAbsent(nodeA, () => List<Edge>());
    adjacencies.putIfAbsent(nodeB, () => List<Edge>());

    var edgeAtoB = Edge(nodeA, nodeB, weight, parentWay);
    var edgeBtoA = Edge(nodeB, nodeA, weight, parentWay);

    adjacencies[nodeA].add(edgeAtoB);
    adjacencies[nodeB].add(edgeBtoA);

    edgeAtoB.back = edgeBtoA;
    edgeBtoA.back = edgeAtoB;

    penalties.putIfAbsent(edgeAtoB, () => parentWay.initialPenalty);
    penalties.putIfAbsent(edgeBtoA, () => parentWay.initialPenalty);
  }

  int getNodeCount() {
    return adjacencies.length;
  }

  void penalizeEdgesAlongRoute(List<Edge> route, double penalty){
    for(var edge in route){
      penalties[edge] *= penalty;
      penalties[edge.back] *= penalty;
    }
  }

  List<Node> edgeToNodes(Edge edge) {
    List<Node> result = List<Node>();
    bool startAdding = false;
    bool reverseResult = false;
    for (var node in edge.parentWay.childNodes) {
      if (node == edge.nodeFrom && !startAdding) startAdding = true;
      if (node == edge.nodeTo && !startAdding) {
        startAdding = true;
        reverseResult = true;
      }
      if (startAdding) result.add(node);
      if (node == edge.nodeTo && startAdding && !reverseResult) break;
      if (node == edge.nodeFrom && startAdding && reverseResult) break;
    }
    if(reverseResult) return result.reversed.toList();
    else return result;
  }


  List<Edge> AStar(Node start, Node end) {
    //Implemented from pseudocode from Wikipedia. Copied the comments from there es well for better understanding
    //https://en.wikipedia.org/wiki/A*_search_algorithm

    // The set of discovered nodes that may need to be (re-)expanded.
    // Initially, only the start node is known.
    Set<Node> openSet = Set();
    openSet.add(start);

    // h is the heuristic function. h(n) estimates the cost to reach goal from node n.
    h(Node node) => OsmData.getDistance(node, end);

    // For node n, cameFrom[n] is the edge immediately preceding it on the cheapest path from start to n currently known.
    Map<Node, Edge> cameFrom = Map();
    List<Edge> reconstructPath(Node current) {
      var totalPath = List<Edge>();
//      totalPath.add(current);
      while (cameFrom.containsKey(current)) {
        totalPath.insert(0, cameFrom[current]);
        current = cameFrom[current].nodeFrom;
      }
      return totalPath;
    }

    // For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
    Map<Node, double> gScore = Map();
    gScore[start] = 0;

    // For node n, fScore[n] := gScore[n] + h(n).
    Map<Node, double> fScore = Map();
    fScore[start] = h(start);

    while (openSet.isNotEmpty) {
      var current = openSet.reduce((curr, next) =>
      (fScore[curr] ?? double.infinity) < (fScore[next] ?? double.infinity)
          ? curr
          : next);
      if (current == end) {
        return reconstructPath(current);
      }
      openSet.remove(current);
      for (Edge neighborEdge in adjacencies[current]) {
        // d(current,neighbor) is the weight of the edge from current to neighbor
        // tentative_gScore is the distance from start to the neighbor through current
        var tentativeGScore = (gScore[current] ?? double.infinity) +
            neighborEdge.weight * penalties[neighborEdge];
        var neighbor = neighborEdge.nodeTo;
        if (tentativeGScore < (gScore[neighbor] ?? double.infinity)) {
          // This path to neighbor is better than any previous one. Record it!
          cameFrom[neighbor] = neighborEdge;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = tentativeGScore + h(neighbor);
          openSet.add(neighbor);
        }
      }
    }
    return null;
  }

}

class OsmData{
  HashSet<Node> nodes;
  List<Way> ways;
  Graph graph;
  rtree.RTree locationIndex;

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

  //Todo: improve this distance function. Right now it assumes the earth is flat (which might be true).
  //http://edwilliams.org/avform.htm#Dist
  static double getDistance(Node nodeA, Node nodeB){
    var a = (nodeA.latitude - nodeB.latitude).abs();
    var b = (nodeA.longitude - nodeB.longitude).abs();
    return sqrt(a*a + b*b);
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
          //Todo: Maybe add the List of nodes to each edge right here, so those don't have to be reconstructed after the routing algorithm finished
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

  List<double> projectCoordinate(double latInDeg, double longInDeg, double distanceInM, double headingFromNorth){
    var latInRadians = (latInDeg*pi)/180.0;
    var longInRadians = (longInDeg*pi)/180.0;
    var headingInRadians = (headingFromNorth*pi)/180.0;

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

  void buildLocationIndex(){
    if(graph == null) {
      print('graph has to be built before locationIndex');
      return;
    }
    locationIndex = rtree.RTree();
    for(Node node in graph.adjacencies.keys){
      var nodeRect = Rectangle(node.latitude, node.longitude, 0.1,0.1);
      locationIndex.insert(rtree.RTreeDatum(nodeRect, node));
    }
  }
  //This is a suboptimal solution, but its all i can do right now without implementing an rtree myself
  //something like this  https://blog.mapbox.com/a-dive-into-spatial-search-algorithms-ebd0c5e39d2a (knn nearest neighbor search)
  //would be better, but the rtree package doesn't give access to the root node, which would be required to implement that algorithm
  Node getClosestToPoint(double latitude, double longitude){
    var topLeft = projectCoordinate(latitude, longitude, 50, 315);
    var bottomRight = projectCoordinate(latitude, longitude, 50, 135);
    var searchRect = Rectangle.fromPoints(Point(topLeft[0], topLeft[1]), Point(bottomRight[0], bottomRight[1]));
    var closeNodes = locationIndex.search(searchRect);
    return closeNodes.map((datum) => datum.value)
        .reduce((curr, next) => OsmData.getDistance(curr, Node(0, latitude, longitude))
        < OsmData.getDistance(next, Node(0, latitude, longitude)) ? curr:next);
  }

  Future<List<List<Node>>> calculateRoundTrip(double startLat, double startLong, double distanceInMeter, int alternativeRouteCount) async{
    var jsonNodesAndWays = await getWaysJson(startLat, startLong, distanceInMeter/2);
    _importJsonNodesAndWays(jsonNodesAndWays);
    var randomGenerator = Random(1);
    List<List<Node>> result = List();
    for(var i =0; i<alternativeRouteCount; i++){
      var initialHeading = randomGenerator.nextInt(360).floorToDouble();
      var pointB = projectCoordinate(startLat, startLong, distanceInMeter/3, initialHeading);
      var pointC = projectCoordinate(startLat, startLong, distanceInMeter/3, initialHeading + 60);

      var nodeA = getClosestToPoint(startLat, startLong);
      var nodeB = getClosestToPoint(pointB[0], pointB[1]);
      var nodeC = getClosestToPoint(pointC[0], pointC[1]);

      var aToB = graph.AStar(nodeA, nodeB);
      graph.penalizeEdgesAlongRoute(aToB, 2);
      var bToC = graph.AStar(nodeB, nodeC);
      graph.penalizeEdgesAlongRoute(bToC, 2);
      var cToA = graph.AStar(nodeC, nodeA);
      graph.penalizeEdgesAlongRoute(cToA, 2);

      var routeAlternative = aToB;
      routeAlternative.addAll(bToC);
      routeAlternative.addAll(cToA);

      var routeAlternativeNodes = List<Node>();
      routeAlternative.forEach((edge) => routeAlternativeNodes.addAll(graph.edgeToNodes(edge)));
      result.add(routeAlternativeNodes);
    }

    return result;
  }

  void _importJsonNodesAndWays(String jsonNodesAndWays){
    var jsonDecoder = JsonDecoder();
    dynamic parsedData = jsonDecoder.convert(jsonNodesAndWays)['elements'];
    parsedData.forEach((element) => parseToObject(element));
    buildGraph();
    buildLocationIndex();
  }

   Future<String> getWaysJson(double aroundLat, double aroundLong, radius) async {
    var topLeftBoundingBox = projectCoordinate(aroundLat, aroundLong, radius, 315);
    var northernBorder = topLeftBoundingBox[0];
    var westernBorder = topLeftBoundingBox[1];
    var bottomRightBoundingBox = projectCoordinate(aroundLat, aroundLong, radius, 135);
    var southernBorder = bottomRightBoundingBox[0];
    var easternBorder = bottomRightBoundingBox[1];

    var url = 'http://overpass-api.de/api/interpreter?data=[bbox:$southernBorder, $westernBorder, $northernBorder, $easternBorder]'
        '[out:json][timeout:300]'
        ';way["highway"](around:$radius,$aroundLat, $aroundLong);'
//        ';way["highway"~"footway|cyclepath|track|path|residential|unclassified|service"](around:$radius,$aroundLat, $aroundLong);'
        '(._;>;); out body qt;';

    var response = await http.get(url);
    if(response.statusCode != 200) print("OSM request failed. Statuscode:" + response.statusCode.toString() + "\n Message: " + response.body);
    return response.body;
}

}

void main() async{

  var osmData = OsmData();
  var route = await osmData.calculateRoundTrip(52.510143, 13.408564, 10000, 90);
  print(route.length);
}
