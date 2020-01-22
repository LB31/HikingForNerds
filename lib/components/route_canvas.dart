import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/routing/node.dart';

class RouteCanvasWidget extends StatelessWidget {
  final double width, height;
  final List<Node> nodes;
  final double innerPadding;
  final Color backgroundColor;
  final Color lineColor;
  final double strokeWidth;

  const RouteCanvasWidget(this.width, this.height, this.nodes,
      {this.innerPadding = 0.2,
      this.backgroundColor = Colors.white70,
      this.lineColor = Colors.black,
      this.strokeWidth = 1.5});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: CustomPaint(
            painter: RoutePainter(
                width,
                height,
                getPointsFromNodes(this.nodes, this.innerPadding),
                this.lineColor,
                this.strokeWidth)),
      ),
    );
  }

  List<Offset> getPointsFromNodes(List<Node> nodes, double innerPadding) {
    double minLat = double.maxFinite,
        minLon = double.maxFinite,
        maxLat = double.minPositive,
        maxLon = double.minPositive;

    for (Node node in nodes) {
      if (node.latitude < minLat) minLat = node.latitude;
      if (node.latitude > maxLat) maxLat = node.latitude;
      if (node.longitude < minLon) minLon = node.longitude;
      if (node.longitude > maxLon) maxLon = node.longitude;
    }

    double centerLat = (maxLat + minLat) / 2.0;
    double centerLon = (maxLon + minLon) / 2.0;

    List<Offset> points = new List<Offset>();

    for (Node node in nodes) {
      points.add(Offset(node.latitude - centerLat, node.longitude - centerLon));
    }

    double horizontalPadding = (width / 2) * innerPadding;
    double verticalPadding = (height / 2) * innerPadding;
    double latScale = ((width / 2) - horizontalPadding) / (maxLat - centerLat);
    double lonScale = ((height / 2) - verticalPadding) / (maxLon - centerLon);

    return points
        .map((e) => Offset(
            e.dx * latScale + (width / 2), e.dy * lonScale + (height / 2)))
        .toList();
  }
}

class RoutePainter extends CustomPainter {
  final double width, height;
  final List<Offset> points;
  final Color lineColor;
  final double strokeWidth;

  const RoutePainter(
      this.width, this.height, this.points, this.lineColor, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = new Paint();
    paint.color = this.lineColor;
    paint.strokeWidth = this.strokeWidth;

    for (int i = 0; i < this.points.length - 1; i++) {
      canvas.drawLine(this.points[i], this.points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
