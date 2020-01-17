import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';

class ElevationChart extends StatefulWidget {
  final HikingRoute route;
  final bool interactive;
  final bool withLabels;

  final Function(int) onSelectionChanged;

  @override
  State<StatefulWidget> createState() => new ElevationChartState();

  ElevationChart(this.route, {this.onSelectionChanged, this.interactive = true, this.withLabels = true});

  List<charts.Series<RouteData, double>> createData(HikingRoute route) {

    final List<RouteData> chartData = new List();

    double lastDistance = 0;
    for (int i = 0; i < route.elevations.length; i++) {
      double distance = 0;
      if (i > 0) {
        distance = OsmData.getDistance(route.path[i - 1], route.path[i]) * 1000; // * 1000; for testing with smaller routes
        distance += lastDistance;
        lastDistance = distance;
      }
      chartData.add(new RouteData(route.elevations[i], distance, i));
    }

    return [
      new charts.Series<RouteData, double>(
        id: 'route',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (RouteData routeData, _) => routeData.distance,
        measureFn: (RouteData routeData, _) => routeData.elevation,
        data: chartData,
      ),
    ];
  }

  _onSelectionChanged(charts.SelectionModel<num> model) {
    final selectedDatum = model.selectedDatum;
    if (selectedDatum.isNotEmpty) {
      selectedDatum.forEach(
              (charts.SeriesDatum datumPair) {
            onSelectionChanged(datumPair.datum.index);
          });
    }
  }
}

class ElevationChartState extends State<ElevationChart>{
  num _sliderDomainValue;
  String _sliderDragState;
  Point<int> _sliderPosition;

  _onSliderChange(Point<int> point, dynamic domain, String roleId,
      charts.SliderListenerDragState dragState) {
    // Request a build.
    void rebuild(_) {
      setState(() {
        _sliderDomainValue = (domain * 10).round() / 10;
        _sliderDragState = dragState.toString();
        _sliderPosition = point;
      });
    }

    widget.onSelectionChanged(((domain * 10).round() / 10).toInt());


    SchedulerBinding.instance.addPostFrameCallback(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    // TODO add localization
    String bottomText = "Distance in m";
    String leftText = "Elevation in m";
    int fontSize = 12;
    charts.SelectionTrigger interaction;

    interaction = widget.interactive
        ? charts.SelectionTrigger.tapAndDrag
        : charts.SelectionTrigger.hover;

    List<charts.ChartBehavior> behaviours = [
      new charts.Slider(
          eventTrigger: interaction, onChangeCallback: _onSliderChange)
    ];

    if (widget.withLabels) {
      behaviours.add(new charts.ChartTitle(bottomText,
          behaviorPosition: charts.BehaviorPosition.bottom,
          titleStyleSpec: new charts.TextStyleSpec(fontSize: fontSize),
          titleOutsideJustification:
          charts.OutsideJustification.middleDrawArea));
      behaviours.add(new charts.ChartTitle(leftText,
          behaviorPosition: charts.BehaviorPosition.start,
          titleStyleSpec: new charts.TextStyleSpec(fontSize: fontSize),
          titleOutsideJustification:
          charts.OutsideJustification.middleDrawArea));
    }

    return new Container(
      child: new charts.LineChart(
        widget.createData(widget.route),
        animate: false,
        defaultRenderer:
        new charts.LineRendererConfig(
            includeArea: true, includeLine: true, stacked: true),
        behaviors: behaviours,
      ),
      decoration: BoxDecoration(
        color: const Color(0xAA7c94b6),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class RouteData {
  final double elevation;
  final double distance;
  final int index;

  RouteData(this.elevation, this.distance, this.index);
}
