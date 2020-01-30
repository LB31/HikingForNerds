import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/geo_utilities.dart';
import 'package:hiking4nerds/styles.dart';

class ElevationChart extends StatefulWidget {
  final HikingRoute route;
  final TouchCallback onTouch;

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
  _ElevationChartState createState() =>
      _ElevationChartState(_createData(route));

  ElevationChart({this.route, this.onTouch});
}

class _ElevationChartState extends State<ElevationChart> {
  final List<FlSpot> routeDataList;
  final FlSpot minSpot;
  final FlSpot maxSpot;

  static final double yAxisThreshold = 1.0;
  static final int yAxisLabelCount = 4;
  static final int xAxisLabelCount = 5;

  factory _ElevationChartState(List<FlSpot> routeDataList) {
    FlSpot minSpot = FlSpot(routeDataList.reduce((current, next) => current.x < next.x ? current : next).x,
        routeDataList.reduce((current, next) => current.y < next.y ? current : next).y - yAxisThreshold);

    FlSpot maxSpot = FlSpot(routeDataList.reduce((current, next) => current.x > next.x ? current : next).x,
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
        Container(
          padding: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: LineChart(
              mainData(),
          ),
        ),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      lineTouchData:
          LineTouchData(getTouchedSpotIndicator: (barData, indicators) {
        if (widget.onTouch != null) {
          int index = indicators.length > 0 ? indicators.first : -1;
          widget.onTouch(index);
        }

        if (indicators == null) {
          return [];
        }
        return indicators.map((int index) {
          /// Indicator Line
          Color lineColor = Colors.white;
          if (barData.dotData.show) {
            lineColor = barData.dotData.dotColor;
          }
          const double lineStrokeWidth = 2;
          final FlLine flLine =
              FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

          /// Indicator dot
          double dotSize = 5;
          Color dotColor = Colors.white;
          if (barData.dotData.show) {
            dotSize = barData.dotData.dotSize * 1.8;
            dotColor = barData.dotData.dotColor;
          }
          final dotData = FlDotData(
            dotSize: dotSize,
            dotColor: dotColor,
          );

          return TouchedSpotIndicatorData(flLine, dotData);
        }).toList();
      }),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
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
          textStyle: TextStyle(
              color: const Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 14),
          getTitles: (value) {
            double difference = maxSpot.x - minSpot.x;
            return value % (difference ~/ xAxisLabelCount) == 0
                ? value.toStringAsFixed(0) + " km"
                : '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: TextStyle(
            color: const Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            double difference = maxSpot.y - minSpot.y;
            return value % (difference ~/ yAxisLabelCount) == 0
                ? value.toStringAsFixed(0) + " m"
                : '';
          },
          reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: minSpot.x,
      maxX: maxSpot.x,
      minY: minSpot.y,
      maxY: maxSpot.y,
      lineBarsData: [
        LineChartBarData(
          spots: routeDataList,
          isCurved: false,
          colors: gradientColors,
          barWidth: 1,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}

/// changes current segment to specified segment, optionally
/// pop previous segment to root page
typedef TouchCallback = void Function(int index);
