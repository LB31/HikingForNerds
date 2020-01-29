import 'package:flutter/material.dart';
import 'package:hiking4nerds/navigation/segment_navigator.dart';
import 'package:hiking4nerds/services/sharing/import_service.dart';
import 'navigation/bottom_navigation.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  AppSegment _currentSegment = AppSegment.setup;
  final Map<AppSegment, GlobalKey<NavigatorState>> _navigatorKeys = {
    AppSegment.setup: GlobalKey<NavigatorState>(),
    AppSegment.map: GlobalKey<NavigatorState>(),
    AppSegment.history: GlobalKey<NavigatorState>(),
    AppSegment.more: GlobalKey<NavigatorState>(),
  };

  void selectSegment(AppSegment segment) {
    setState(() => _currentSegment = segment);
  }

  final GlobalKey navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await _navigatorKeys[_currentSegment].currentState.maybePop(),
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            _buildOffstageNavigator(AppSegment.setup),
            _buildOffstageNavigator(AppSegment.map),
            _buildOffstageNavigator(AppSegment.history),
            _buildOffstageNavigator(AppSegment.more),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          currentSegment: _currentSegment,
          onSelectSegment: _selectSegment,
        ),
      ),
    );
  }

  void changeSegment(AppSegment segment, [bool popToRoot = false]) {
    if (popToRoot) {
      // pop to first route
      _navigatorKeys[_currentSegment]
          .currentState
          .popUntil((route) => route.isFirst);
    }
    _selectSegment(segment);
  }

  void _selectSegment(AppSegment segment) {
    if (segment == _currentSegment) {
      // pop to first route
      _navigatorKeys[segment].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentSegment = segment);
    }
  }

  Widget _buildOffstageNavigator(AppSegment segment) {
    return Offstage(
      offstage: _currentSegment != segment,
      child: SegmentNavigator(
        navigatorKey: _navigatorKeys[segment],
        segment: segment,
        onChangeSegment: changeSegment,
      ),
    );
  }
}
