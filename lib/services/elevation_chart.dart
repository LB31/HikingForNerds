import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
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
}

class ElevationChartState extends State<ElevationChart>{
  RouteData selectedRouteData = new RouteData(0, 0, 0);

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
      new charts.SelectNearest(eventTrigger: interaction, )
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
      behaviours.add(new charts.RangeAnnotation([
        new charts.LineAnnotationSegment(selectedRouteData.distance, charts.RangeAnnotationAxisType.domain, startLabel: selectedRouteData.elevation.toString())])
      );
    } else {
      behaviours.add(new charts.LinePointHighlighter(
          showHorizontalFollowLine:
          charts.LinePointHighlighterFollowLineType.none,
          showVerticalFollowLine:
          charts.LinePointHighlighterFollowLineType.nearest),
      );
    }

    return new Container(
      child: new charts.LineChart(
        _createData(widget.route),
        animate: false,
        defaultRenderer: new charts.LineRendererConfig(
            includeArea: true, includeLine: true, stacked: true),
        behaviors: behaviours,
        selectionModels: [
          new charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: _onSelectionChanged,
          )
        ],
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

  List<charts.Series<RouteData, double>> _createData(HikingRoute route) {
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

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    if (selectedDatum.isNotEmpty) {
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        widget.onSelectionChanged(datumPair.datum.index);
        setState(() {
          this.selectedRouteData = datumPair.datum;
        });
      });
    }
  }
}

class RouteData {
  final double elevation;
  final double distance;
  final int index;

  RouteData(this.elevation, this.distance, this.index);
}


