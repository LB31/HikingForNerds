import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/route.dart';

class ElevationChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  int index;

  ElevationChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory ElevationChart.withData(HikingRoute route) {
    return new ElevationChart(
      _createData(route),
      // Disable animations for image tests.
      animate: false,
    );
  }

  int getSelectedPosition(){
    return index;
  }

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(
      seriesList,
      defaultRenderer:
          new charts.LineRendererConfig(includeArea: true, stacked: true),
      animate: animate,
      behaviors: [
        new charts.SelectNearest(
            eventTrigger: charts.SelectionTrigger.tapAndDrag)
      ],
      selectionModels: [
        new charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<RouteChart, double>> _createData(HikingRoute route) {


    final List<RouteChart> chartData = new List();


    for (var i = 0; i < route.elevations.length; i++) {
      chartData.add(new RouteChart(route.elevations[i].toDouble(), i.toDouble(), i));
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
