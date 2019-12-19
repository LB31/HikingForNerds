import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/route.dart';

class ElevationChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final bool interactive;
  final bool withLabels;

  int index;

  ElevationChart(this.seriesList,
      {this.animate, this.interactive, this.withLabels});

  /// Creates a [LineChart] with sample data and no transition.
  factory ElevationChart.withData(HikingRoute route,
      [bool interactive, bool withLabels]) {
    return new ElevationChart(
      _createData(route),
      // Disable animations for image tests.
      animate: false,
      interactive: interactive != null ? interactive : false,
      withLabels: withLabels != null ? withLabels : false,
    );
  }

  int getSelectedPosition() {
    return index;
  }

  @override
  Widget build(BuildContext context) {
    String bottomText = withLabels ? "Distance" : "";
    String leftText = withLabels ? "Elevation in m" : "";

    List<charts.ChartBehavior> behaviours = [
      new charts.SelectNearest(
              eventTrigger: charts.SelectionTrigger.tapAndDrag)
    ];

    if(withLabels){
      behaviours.add(new charts.ChartTitle(bottomText,
              behaviorPosition: charts.BehaviorPosition.bottom,
              titleStyleSpec: new charts.TextStyleSpec(fontSize: 10),
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea));
          
    }


    return new Container(
      child: new charts.LineChart(
        seriesList,
        defaultRenderer:
            new charts.LineRendererConfig(includeArea: true, stacked: true),
        animate: animate,
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

  /// Create one series with sample hard coded data.
  static List<charts.Series<RouteChart, double>> _createData(
      HikingRoute route, [bool interactive, bool withLabels]) {
    route.elevations = [3.3, 2.1, 5.2, 5, 3, 2, 5];

    final List<RouteChart> chartData = new List();

    for (var i = 0; i < route.elevations.length; i++) {
      chartData
          .add(new RouteChart(route.elevations[i].toDouble(), i.toDouble(), i));
    }

    return [
      new charts.Series<RouteChart, double>(
        id: '',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (RouteChart sales, _) => sales.distance,
        measureFn: (RouteChart sales, _) => sales.elevation,
        data: chartData,
      ),
    ];
  }

  _onSelectionChanged(charts.SelectionModel<num> model) {
    final selectedDatum = model.selectedDatum;
    if (selectedDatum.isNotEmpty) {
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        this.index = datumPair.datum.index;
        print(datumPair.datum.index);
      });
    }
  }
}

/// Sample linear data type.
class RouteChart {
  final double elevation;
  final double distance;
  final int index;

  RouteChart(this.elevation, this.distance, this.index);
}
