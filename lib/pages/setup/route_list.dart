import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/route_canvas.dart';
import 'package:hiking4nerds/services/elevation_chart.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';
import 'package:hiking4nerds/services/routeparams.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';

class RouteList extends StatefulWidget {
  final RouteParamsCallback onPushRoutePreview;
  final RouteParams routeParams;

  RouteList({@required this.onPushRoutePreview, this.routeParams});

  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  List<RouteListEntry> _routeList = [];
  String _title = '';
  bool _routesCalculated = false;

  @override
  void initState() {
    super.initState();
    calculateRoutes();
  }

  Future<void> calculateRoutes() async {
    List<HikingRoute> routes;

    try {
      routes = await OsmData().calculateHikingRoutes(
          widget.routeParams.startingLocation.latitude,
          widget.routeParams.startingLocation.longitude,
          widget.routeParams.distanceKm * 1000.0,
          10,
          widget.routeParams.poiCategories);
    } on NoPOIsFoundException catch (err) {
      print("no poi found exception " + err.toString());
      routes = await OsmData().calculateHikingRoutes(
        widget.routeParams.startingLocation.latitude,
        widget.routeParams.startingLocation.longitude,
        widget.routeParams.distanceKm * 1000.0,
        10);
    }

    routes = routes.toList(growable: true);
    routes.removeWhere((elem) => elem == null);

    await buildRouteTitles(routes);

    setState(() {
      widget.routeParams.routes = routes;
      widget.routeParams.routes.forEach((r) => _routeList.add(RouteListEntry(r)));
      if(routes.length > 0) _title = routes[0].title;
      this._routesCalculated = true;
    });

  }

  // TODO add localization or remove if not needed
  headerText() {
    String paramTitles = 'Start: ';
    (_title.length > 20) ? paramTitles += '\n\nDistance: ' : paramTitles += '\nDistance: ';
    if(widget.routeParams.poiCategories.length > 0) {
      paramTitles += '\nPOIs: ';
      for(var i = 1; i < widget.routeParams.poiCategories.length; i++) paramTitles += '\n';
      // widget.routeParams.poiCategories.forEach((p) => paramTitles += '\n');
    }
    paramTitles += '\nAltitude differences: ';

    String params = '$_title';
    params += '\n${widget.routeParams.distanceKm.toInt()} KM / ${(widget.routeParams.distanceKm*12).toInt()} MIN';
    if(widget.routeParams.poiCategories.length > 0) {
      widget.routeParams.poiCategories.forEach((p) => params += '\n$p ');
    }
    params += '\n${AltitudeTypeHelper.asString(widget.routeParams.altitudeType)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child:
              Text(paramTitles,
                style: TextStyle(
                // fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
                textAlign: TextAlign.left,
              ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child:
              Text(params,
                style: TextStyle(
                // fontSize: 14,
                color: Colors.grey[600]),
                textAlign: TextAlign.left,
              ),
          ),
        ],
      ),
    );
  }

  chips(RouteListEntry r) {
    List<Widget> chips = List();
    // TODO remove test setup when POIs are available
    if(r.pois == null || r.pois.isEmpty) {
      r.pois.add('PLACEHOLDER');
      r.pois.add('PLACEHOLDER');
      r.pois.add('PLACEHOLDER');
    }
    r.pois.forEach((p) {
      chips.add(
        RawMaterialButton(
          onPressed: () {},
          constraints: BoxConstraints(),
          padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
          child: Text(p, style: TextStyle(fontSize: 10.0)),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
          ),
          fillColor: htwGreen,
        ));

      //   Transform(
      //   transform: Matrix4.identity()..scale(0.6),
      //   child: Chip(
      //     label: Text(p, style: TextStyle(fontSize: 12.0)),
      //     backgroundColor: htwGreen,
      //     labelPadding: EdgeInsets.all(2),
      //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //   ),
      // ));
    });
    
    return chips;
  }

  buildSub(RouteListEntry r) {

    Text text = Text('\n${r.distance} KM\n\n${r.time} MIN\n\n\n');

    Wrap content = Wrap(
      children: chips(r),
      spacing: 1.0,
      alignment: WrapAlignment.start,
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: content,
          flex: 7,
        ),
        Expanded(
          child: text,
          flex: 1,
        )
      ],
    );
  }

  Future<void> buildRouteTitles(List<HikingRoute> routes) async{
    for(int i = 0; i < routes.length; i++){
      String title = await routes[i].buildTitle();
      routes[i].setTitle(title);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if(_routesCalculated) {
      body = 
        Column(
        children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 4)),
          headerText(),
        Padding(padding: EdgeInsets.only(top: 4)),
        Expanded(
          child: ListView.builder(
            itemCount: _routeList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                  const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
                child: Card(
                  child: ListTile(
                    onTap: () {
                      widget.routeParams.routeIndex = index;
                      widget.onPushRoutePreview(widget.routeParams);
                    },
                    subtitle: buildSub(_routeList[index]),
                    leading: _routeList[index].routeCanvas,
                    isThreeLine: true,
                  ),
                ),
              );
            },
          ),
        )]);
    }
    else {
      body = Center(
        child: new CircularProgressIndicator(),
      );
    }

    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: htwGreen,
          title: Text(LocalizationService().getLocalization(english: "Choose a route to preview", german: "Route für Vorschau wählen")),
          elevation: 0,
        ),
        body: body
      );
  }
}

class RouteListEntry {
  String title; // Route title i.e. Address, city, regio, custom
  String date; // Route date - created
  String distance; // Route length in KM
  String time; // Route time needed in Minutes
  RouteCanvasWidget routeCanvas;
  ElevationChart chart;
  List<String> pois = [];

  // RouteListTile({ this.title, this.date, this.distance, this.avatar });

  RouteListEntry(HikingRoute r) {
    this.title = r.title;
    this.date = r.date;
    this.distance = formatDistance(r.totalLength);
    this.time = (r.totalLength * 12).toInt().toString();
    this.routeCanvas = RouteCanvasWidget(100, 100, r.path, lineColor: htwGreen,);
    (r.elevations != null) ? this.chart = ElevationChart(r, interactive: false, withLabels: false,) : print('NO ALTITUDE INFORMATION AVAILABLE');
    // TODO remove placeholder when pois are available
    if (r.pointsOfInterest != null) r.pointsOfInterest.forEach((p) => { if( !pois.contains(p.getCategory) ) pois.add(p.getCategory() )});
  }

  String formatDistance(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}