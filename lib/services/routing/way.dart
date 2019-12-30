import 'node.dart';
import 'osmdata.dart';

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