import 'package:flutter/material.dart';
import 'package:hiking4nerds/navigation/bottom_navigation.dart';
import 'package:hiking4nerds/pages/history.dart';
import 'package:hiking4nerds/pages/home.dart';
import 'package:hiking4nerds/pages/more/credits.dart';
import 'package:hiking4nerds/pages/more/help.dart';
import 'package:hiking4nerds/pages/more/more.dart';
import 'package:hiking4nerds/pages/setup/locationselection.dart';

class SegmentRoutes {
  static const String root = '/';
  static const String locationSelection = '/setup/locationselection';
  static const String routePreferences = '/setup/routepreferences';
  static const String routeList = '/setup/routelist';
  static const String routePreview = '/setup/routepreview';
  static const String help = '/more/help';
  static const String credits = '/more/credits';
}

class SegmentNavigator extends StatelessWidget {
  SegmentNavigator({@required this.navigatorKey, @required this.segment, @required this.onChangeSegment});

  final GlobalKey<NavigatorState> navigatorKey;
  final AppSegment segment;
  final ChangeSegmentCallback onChangeSegment;

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      SegmentRoutes.root: (context) => _findRootPage(context, segment),
      SegmentRoutes.credits: (context) => Credits(),
      SegmentRoutes.help: (context) => Help(
          onPushHistorySaveState: () => onChangeSegment(AppSegment.history),
          onPushHistory: () => onChangeSegment(AppSegment.history, true)),
      // TODO add routePreferences, routeList, routePreview and more if needed
    };
  }

  void _push(BuildContext context, String route) {
    var routeBuilders = _routeBuilders(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => routeBuilders[route](context),
      ),
    );
  }

  Widget _findRootPage(BuildContext context, AppSegment segment) {
    switch (segment) {
      case AppSegment.setup:
        return LocationSelection(
            onPushRoutePreferences: () =>
                _push(context, SegmentRoutes.routePreferences));
      case AppSegment.map:
        return Home();
      case AppSegment.history:
        return History();
      case AppSegment.more:
        return More(
            onPushCredit: () => _push(context, SegmentRoutes.credits),
            onPushHelp: () => _push(context, SegmentRoutes.help));
    }

    throw new Exception(
        "SegmentNavigator: Segment not specified for " + segment.toString());
  }

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders(context);
    return Navigator(
      key: navigatorKey,
      initialRoute: SegmentRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name](context),
        );
      },
    );
  }
}

typedef ChangeSegmentCallback = void Function(AppSegment segment, [bool popToFirst]);
