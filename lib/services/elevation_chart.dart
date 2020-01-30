import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/geo_utilities.dart';
import 'package:hiking4nerds/styles.dart';

class ElevationChart extends StatefulWidget {
  final HikingRoute route;

  List<FlSpot> _createData(HikingRoute route) {
    final List<FlSpot> chartData = new List();

    double lastDistance = 0;
    for (int i = 0; i < route.elevations.length; i++) {
      double distance = 0;
      if (i > 0) {
        distance = getDistance(route.path[i - 1], route.path[i]);
        distance += lastDistance;
        lastDistance = distance;
      }
      chartData.add(new FlSpot(distance, route.elevations[i]));
    }

    return chartData;
  }

  @override
  _ElevationChartState createState() => _ElevationChartState(_createData(route));

  ElevationChart(this.route);
}

class _ElevationChartState extends State<ElevationChart> {
  final List<FlSpot> routeDataList;
  final FlSpot minSpot;
  final FlSpot maxSpot;

  static final double yAxisThreshold = 1.0;
  static final int yAxisLabelCount = 4;
  static final int xAxisLabelCount = 5;

  factory _ElevationChartState(List<FlSpot> routeDataList){

    FlSpot minSpot = FlSpot(
        routeDataList.reduce((current, next) => current.x < next.x ? current : next).x,
        routeDataList.reduce((current, next) => current.y < next.y ? current : next).y - yAxisThreshold);

    FlSpot maxSpot = FlSpot(
        routeDataList.reduce((current, next) => current.x > next.x ? current : next).x,
        routeDataList.reduce((current, next) => current.y > next.y ? current : next).y + yAxisThreshold);

    return _ElevationChartState._(routeDataList, minSpot, maxSpot);
  }

  _ElevationChartState._(this.routeDataList, this.minSpot, this.maxSpot);

  List<Color> gradientColors = [
    htwGreen,
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                color: const Color(0xAA7c94b6)),
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 25,
          textStyle:
          TextStyle(color: const Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 16),
          getTitles: (value) {
            double difference = maxSpot.x - minSpot.x;
            return value % (difference ~/ xAxisLabelCount)  == 0 ? value.toString() : '';
          },
          margin: 10,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: TextStyle(
            color: const Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            double difference = maxSpot.y - minSpot.y;
            return value % (difference ~/ yAxisLabelCount)  == 0 ? value.toString() : '';
          },
          reservedSize: 28,
          margin: 10,
        ),
      ),
      borderData:
      FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: minSpot.x,
      maxX: maxSpot.x,
      minY: minSpot.y,
      maxY: maxSpot.y,
      lineBarsData: [
        LineChartBarData(
          spots: routeDataList,
          isCurved: true,
          colors: gradientColors,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}