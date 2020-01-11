import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/routing/way.dart';

class Edge{
  Node nodeFrom;
  Node nodeTo;
  double weight;
  Way parentWay;
  Edge back;

  Edge(this.nodeFrom, this.nodeTo, this.weight, this.parentWay);
}