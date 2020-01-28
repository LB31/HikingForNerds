import 'dart:collection';
import 'dart:convert';
import 'package:hiking4nerds/services/routing/geo_utilities.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:quiver/core.dart';
import 'package:collection/collection.dart';
import 'package:hiking4nerds/services/routing/edge.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/routing/way.dart';

class Graph {
  Map<Node, List<Edge>> adjacencies;
  Map<Edge, double> roadTypePenalties; //factor that penalizes edges, for example when they were used already in a roundtrip
  Map<Edge, double> edgeAlreadyUsedPenalties; //factor that penalizes edges, for example when they were used already in a roundtrip
  static const bool PROFILING = true;

  void addEdge(Node nodeA, Node nodeB, double weight, Way parentWay) {
    adjacencies.putIfAbsent(nodeA, () => List<Edge>());
    adjacencies.putIfAbsent(nodeB, () => List<Edge>());

    var edgeAtoB = Edge(nodeA, nodeB, weight, parentWay);
    var edgeBtoA = Edge(nodeB, nodeA, weight, parentWay);

    adjacencies[nodeA].add(edgeAtoB);
    adjacencies[nodeB].add(edgeBtoA);

    edgeAtoB.back = edgeBtoA;
    edgeBtoA.back = edgeAtoB;

    roadTypePenalties.putIfAbsent(edgeAtoB, () => parentWay.initialPenalty);
    roadTypePenalties.putIfAbsent(edgeBtoA, () => parentWay.initialPenalty);
  }

  Graph(String jsonNodesAndWays) {
    var graphBuildTimestamp = DateTime.now().millisecondsSinceEpoch;
    adjacencies = Map();
    roadTypePenalties = Map();
    edgeAlreadyUsedPenalties = Map();

    var jsonDecoder = JsonDecoder();
    dynamic parsedData = jsonDecoder.convert(jsonNodesAndWays)['elements'];

    HashSet<Node> nodes = HashSet();
    List<Way> ways = List();

    for (var element in parsedData) {
      if (element['type'] == 'node') {
        nodes.add(Node(element['id'], element["lat"], element["lon"]));
      }
      if (element['type'] == 'way') {
        double wayPenalty;
        if (RegExp(
            r"motorway|trunk|primary|motorway_link|trunk_link|primary_link")
            .hasMatch(element['tags']['highway'])) {
          wayPenalty = 20;
        }
        else
        if (RegExp(r"secondary|tertiary|secondary_link|tertiary_link").hasMatch(
            element['tags']['highway'])) {
          wayPenalty = 8;
        }
        else if (RegExp(
            r"cyclepath|track|path|bridleway|sidewalk|residential|service")
            .hasMatch(element['tags']['highway'])) {
          wayPenalty = 2;
        }
        else if (RegExp(r"footway|pedestrian|unclassified").hasMatch(
            element['tags']['highway'])) {
          wayPenalty = 1;
        } else {
          wayPenalty = 5;
        }
        ways.add(Way(
            element['id'], element['nodes'].cast<int>(), nodes, wayPenalty));
      }
    }

    Map<Node, int> nodeCount = Map();
    for (Way way in ways) {
      for (Node node in way.childNodes) {
        nodeCount.putIfAbsent(node, () => 0);
        nodeCount[node]++;
      }
    }
    for (Way way in ways) {
      var lastIntersection = way.childNodes.first;
      var lastNode = way.childNodes.first;
      double currentLength = 0;
      for (Node node in way.childNodes) {
        currentLength += getDistance(lastNode, node);
        lastNode = node;
        if (nodeCount[node] > 1 && node != lastIntersection) {
          addEdge(lastIntersection, node, currentLength, way);
          currentLength = 0;
          lastIntersection = node;
        }
        else if (node == way.childNodes.last) {
          addEdge(lastIntersection, node, currentLength, way);
        }
      }
    }
    if(PROFILING) print(adjacencies.keys.length.toString() + " Vertices put in graph in " + (DateTime.now().millisecondsSinceEpoch - graphBuildTimestamp).toString() + " ms");
  }

  int getNodeCount() {
    return adjacencies.length;
  }

  double lengthOfEdgesKM(List<Edge> edges){
    return edges.map((edge) => edge.weight).fold(0.0, (curr, next) => curr + next);
  }

  void penalizeEdgesAlongRoute(List<Edge> route, double penalty){
    for(var edge in route){
      edgeAlreadyUsedPenalties.putIfAbsent(edge, () => penalty);
      edgeAlreadyUsedPenalties.putIfAbsent(edge.back, () => penalty);
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

  Node getClosestNodeToCoordinates(double latitude, double longitude){
    var pointDummy = LatLng(latitude, longitude);
    var closestPoint = adjacencies.keys.reduce((curr, next) => getDistance(pointDummy, curr) < getDistance(pointDummy, next) ? curr:next);
    return closestPoint;
  }

  Optional<List<Edge>> AStar(Node start, Node end) {
    //Implemented from pseudocode from Wikipedia. Copied the comments from there es well for better understanding
    //https://en.wikipedia.org/wiki/A*_search_algorithm


    // h is the heuristic function. h(n) estimates the cost to reach goal from node n.
    h(Node node) => getDistance(node, end);

    // For node n, cameFrom[n] is the edge immediately preceding it on the cheapest path from start to n currently known.
    Map<Node, Edge> cameFrom = Map();
    Optional<List<Edge>> reconstructPath(Node current) {
      var totalPath = List<Edge>();
//      totalPath.add(current);
      while (cameFrom.containsKey(current)) {
        totalPath.insert(0, cameFrom[current]);
        current = cameFrom[current].nodeFrom;
      }
      return Optional.fromNullable(totalPath);
    }

    // For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
    Map<Node, double> gScore = Map();
    gScore[start] = 0;

    // For node n, fScore[n] := gScore[n] + h(n).
    Map<Node, double> fScore = Map();
    fScore[start] = h(start);

    // The set of discovered nodes that may need to be (re-)expanded.
    // Initially, only the start node is known.
    Set<Node> openSet = HashSet();
    PriorityQueue<Node> openQueue = PriorityQueue((nodeA, nodeB) => (fScore[nodeA] ?? double.infinity).compareTo(fScore[nodeB] ?? double.infinity));
    openSet.add(start);
    openQueue.add(start);

    while (openSet.isNotEmpty) {

      var current = openQueue.removeFirst();
      openSet.remove(current);

      if (current == end) {
        return reconstructPath(current);
      }
      for (Edge neighborEdge in adjacencies[current]) {
        // d(current,neighbor) is the weight of the edge from current to neighbor
        // tentative_gScore is the distance from start to the neighbor through current
        var tentativeGScore = (gScore[current] ?? double.infinity) +
            neighborEdge.weight * (roadTypePenalties[neighborEdge] + (edgeAlreadyUsedPenalties[neighborEdge] ?? 0.0));
        var neighbor = neighborEdge.nodeTo;
        if (tentativeGScore < (gScore[neighbor] ?? double.infinity)) {
          // This path to neighbor is better than any previous one. Record it!
          cameFrom[neighbor] = neighborEdge;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = tentativeGScore + h(neighbor);
          if(openSet.contains(neighbor)){
            openQueue.remove(neighbor);
          }
          openQueue.add(neighbor);
          openSet.add(neighbor);
        }
      }
    }
    return Optional.absent();
  }

}