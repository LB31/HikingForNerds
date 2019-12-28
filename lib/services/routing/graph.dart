import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:hiking4nerds/services/routing/edge.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/routing/way.dart';

import 'osmdata.dart';

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
            neighborEdge.weight * penalties[neighborEdge];
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
    return null;
  }

}