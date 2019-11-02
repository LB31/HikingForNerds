import 'dart:convert';
import 'dart:collection';
import 'dart:ffi';
import 'dart:math';
import 'package:http/http.dart' as http;

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
  List<Node> childNodes;
  Way(this._id, List<int> nodeIds, OsmData dataWithNodes){
    childNodes = List();
    for(int nodeId in nodeIds){
      //adds the actual node object to the way instead of only the node id. Lookup returns the object found in the set,
      //so with an overridden equals method we can get the wanted node by passing that function a dummy node with the required id.
      childNodes.add(dataWithNodes.nodes.lookup(Node(nodeId, 0.0, 0.0)));
    }
  }
}

class Edge{
  Node neighbor;
  double weight;

  Edge(this.neighbor, this.weight);
}

class Graph {
  Map<Node, List<Edge>> adjacencies;

  Graph(){
    adjacencies = Map();
  }

  void addEdge(Node nodeA, Node nodeB, double weight){
    adjacencies.putIfAbsent(nodeA, () => List<Edge>());
    adjacencies.putIfAbsent(nodeB, () => List<Edge>());
    adjacencies[nodeA].add(Edge(nodeB, weight));
    adjacencies[nodeB].add(Edge(nodeA, weight));
  }

  int getNodeCount(){
    return adjacencies.length;
  }


  List<Node> AStar(Node start, Node end){
    //Implemented from pseudocode from Wikipedia. Copied the comments from there es well for better understanding
    //https://en.wikipedia.org/wiki/A*_search_algorithm

    // The set of discovered nodes that may need to be (re-)expanded.
    // Initially, only the start node is known.
    Set<Node> openSet = Set();
    openSet.add(start);

    // h is the heuristic function. h(n) estimates the cost to reach goal from node n.
    h(Node node) => OsmData.getDistance(node, end);

    // For node n, cameFrom[n] is the node immediately preceding it on the cheapest path from start to n currently known.
    Map<Node,Node> cameFrom = Map();
    List<Node> reconstructPath(current){
      var totalPath = List<Node>();
      totalPath.add(current);
      while(cameFrom.containsKey(current)){
        current = cameFrom[current];
        totalPath.insert(0, current);
      }
      return totalPath;
    }

    // For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
    Map<Node, double> gScore = Map();
    gScore[start] = 0;

    // For node n, fScore[n] := gScore[n] + h(n).
    Map<Node, double> fScore = Map();
    fScore[start] = h(start);

    while(openSet.isNotEmpty){
      var current = openSet.reduce((curr, next) => (fScore[curr] ?? double.infinity) < (fScore[next] ?? double.infinity) ? curr : next);
      if(current == end){
        return reconstructPath(current);
      }
      openSet.remove(current);
      for(Edge neighborEdge in adjacencies[current]){
        // d(current,neighbor) is the weight of the edge from current to neighbor
        // tentative_gScore is the distance from start to the neighbor through current
        var tentativeGScore = (gScore[current] ?? double.infinity) + neighborEdge.weight;
        var neighbor = neighborEdge.neighbor;
        if(tentativeGScore < (gScore[neighbor] ?? double.infinity)){
          // This path to neighbor is better than any previous one. Record it!
          cameFrom[neighbor] = current;
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

  OsmData(){
    nodes = HashSet();
    ways = List();
  }

  void parseToObject(Map element){
    if(element['type'] == 'node'){
      nodes.add(Node(element['id'], element["lat"], element["lon"]));
    }
    if(element['type'] == 'way'){
      ways.add(Way(element['id'], element['nodes'].cast<int>(), this));
    }
  }

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
          graph.addEdge(lastIntersection, node, currentLength);
          currentLength = 0;
          lastIntersection = node;
        }
        else if(node == way.childNodes.last){
          graph.addEdge(lastIntersection, node, currentLength);
        }
      }
    }
  }
}

Future<String> getWaysJson() async {
  double southernBorder = 47.987811;
  double westernBorder = 8.166028;
  double northernBorder = 48.008402;
  double easternBorder = 8.198229;
  var url = 'http://overpass-api.de/api/interpreter?data=[bbox:$southernBorder, $westernBorder, $northernBorder, $easternBorder][out:json][timeout:25];(node["name"~"Fernh.usle"];)'
      '->.poi;way["highway"](around:10000)->.poiWays;(.poiWays;.poiWays >;)'
      '->.waysAndTheirNodes;.waysAndTheirNodes out skel qt;';

  var response = await http.get(url);
  return response.body;
}

void main() async{
  String rawData = await getWaysJson();
  var jsonDecoder = JsonDecoder();
  var osmData = OsmData();
  dynamic parsedData = jsonDecoder.convert(rawData)['elements'];
  parsedData.forEach((element) => osmData.parseToObject(element));
  osmData.buildGraph();
  var path = osmData.graph.AStar(Node(300719693, 47.9906575, 8.1934962), Node(318655383, 47.9906117, 8.1726893));
  print(osmData.graph.getNodeCount());
}
