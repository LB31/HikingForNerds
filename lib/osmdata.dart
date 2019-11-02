import 'dart:convert';
import 'dart:collection';
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

  double getDistance(Node nodeA, Node nodeB){
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
  var url = 'http://overpass-api.de/api/interpreter?data=[bbox:47.998150, 8.175187,48.001172, 8.180809][out:json][timeout:25];(node["name"~"Fernh.usle"];)'
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
  print(osmData.graph.getNodeCount());
}
