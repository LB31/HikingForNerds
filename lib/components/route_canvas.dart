import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/routing/node.dart';

class RouteCanvasWidget extends StatelessWidget {
  final double height, width;
  final Color backgroundColor;
  final Color lineColor;
  final List<Node> nodes;

  const RouteCanvasWidget(
      this.height,
      this.width,
      this.nodes,
      [this.backgroundColor,
      this.lineColor);

  @override
  Widget build(BuildContext context) {

    final List<Offset> points = getPointsFromNodes(this.nodes);

    return Center(
      child: Container(
          height: height,
          width: width,
          color: backgroundColor,
          child: CustomPaint(
              painter: RoutePainter(height, width, points)
        ),
      ),
    );
  }

  List<Offset> getPointsFromNodes(List<Node> nodes) {
    double avgLat = 0, avgLon = 0, maxLat = 0, maxLon = 0;

    for (Node node in nodes) {
      avgLat += node.latitude;
      avgLon += node.longitude;
      if (node.latitude.abs() > maxLat)
        maxLat = node.latitude.abs();
      if (node.longitude.abs() > maxLon)
        maxLon = node.longitude.abs();
    }
    avgLat /= nodes.length;
    avgLon /= nodes.length;
    maxLat -= avgLat;
    maxLon -= avgLon;

    double horizontalPadding = (width / 2) * 0.4;
    double verticalPadding = (height / 2) * 0.4;
    double scalingLat = ((width / 2) - horizontalPadding) / maxLat;
    double scalingLon = ((height / 2) - verticalPadding) / maxLon;

    List<Offset> points = new List<Offset>();

    for (Node node in nodes) {
      points.add(Offset((width / 2) + (node.latitude - avgLat) * scalingLat,
          (height / 2) + (node.longitude - avgLon) * scalingLon));
    }
    return points;
  }
}

class RoutePainter extends CustomPainter {
  final double height, width;
  final List<Offset> points;

  const RoutePainter(
      this.height,
      this.width,
      this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = new Paint();
    paint.color = Colors.black;
    paint.strokeWidth = 2.0;

    for (int i = 0; i < this.points.length - 1; i++) {
      canvas.drawLine(this.points[i], this.points[i+1], paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}