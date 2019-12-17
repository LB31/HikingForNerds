import 'dart:ffi';
import 'dart:math';

/// Timeseries chart with example of updating external state based on selection.
///
/// A SelectionModelConfig can be provided for each of the different
/// [SelectionModel] (currently info and action).
///
/// [SelectionModelType.info] is the default selection chart exploration type
/// initiated by some tap event. This is a different model from
/// [SelectionModelType.action] which is typically used to select some value as
/// an input to some other UI component. This allows dual state of exploring
/// and selecting data via different touch events.
///
/// See [SelectNearest] behavior on setting the different ways of triggering
/// [SelectionModel] updates from hover & click events.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SelectionCallbackExample extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SelectionCallbackExample(this.seriesList, {this.animate});

  /// Creates a [charts.TimeSeriesChart] with sample data and no transition.
  factory SelectionCallbackExample.withSampleData() {
    return new SelectionCallbackExample(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }


  // We need a Stateful widget to build the selection details with the current
  // selection as the state.
  @override
  State<StatefulWidget> createState() => new _SelectionCallbackState();

  /// Create one series with sample hard coded data.
  static List<charts.Series<ElevationDistanceSeries, double>> _createSampleData() {
    final uk_data = [
      new ElevationDistanceSeries(12.3, 0, 0),
    ];

    Random rnd = new Random();
    int min = 0, max = 15;
    for (var i = 1; i < 100; i++) {
      int r = min + rnd.nextInt(max - min);
      uk_data.add(new ElevationDistanceSeries(r.toDouble(), i.toDouble(), i));
    }

    return [
      new charts.Series<ElevationDistanceSeries, double>(
        id: 'Batman',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (ElevationDistanceSeries sales, _) => sales.distance,
        measureFn: (ElevationDistanceSeries sales, _) => sales.elevation,
        data: uk_data,
      )
    ];
  }
}

class _SelectionCallbackState extends State<SelectionCallbackExample> {
  Map<String, num> _measures;

  // Listens to the underlying selection changes, and updates the information
  // relevant to building the primitive legend like information under the
  // chart.
  _onSelectionChanged(charts.SelectionModel model) {

    final selectedDatum = model.selectedDatum;

    final measures = <String, num>{};

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    //
    // Walk the selection updating the measures map, storing off the sales and
    // series name for each selection point.
    if (selectedDatum.isNotEmpty) {
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.displayName] = datumPair.datum.index;
      });
    }

    // Request a build.
    setState(() {
      _measures = measures;
    });


  }

  @override
  Widget build(BuildContext context) {
    // The children consist of a Chart and Text widgets below to hold the info.
    final children = <Widget>[
      new SizedBox(
          height: 150.0,
          child: new charts.LineChart(
            widget.seriesList,
            
            animate: widget.animate,
            behaviors: [new charts.SelectNearest(eventTrigger: charts.SelectionTrigger.tapAndDrag)],
            selectionModels: [
              new charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                changedListener: _onSelectionChanged,
              )
            ],
          )),
    ];


    _measures?.forEach((String series, num value) {
      children.add(new Text('${series}: ${value}'));
    });

    return new Column(children: children);
  }
}

/// Sample time series data type.
class ElevationDistanceSeries {
  final double elevation;
  final double distance;
  final int index;

  ElevationDistanceSeries(this.elevation, this.distance, this.index);
}