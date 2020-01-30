import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hiking4nerds/services/database_helpers.dart';
import '../lifecycle_event_handler.dart';
import '../route.dart';
import 'import_export_handler.dart';

class ImportService {
  static const platform =
      const MethodChannel('app.channel.hikingfornerds.data');

  VoidCallback _onSwitchToHistory;
  bool _appSuspended = false;
  HikingRoute _sharedRoute;

  Future<void> suspend() {
    _appSuspended = true;
    return null;
  }

  Future<void> resume() async {
    if (!_appSuspended) return null;

    _sharedRoute = await _getSharedData();
    _appSuspended = false;
    if (_onSwitchToHistory != null && _sharedRoute != null) {
      await DatabaseHelper.instance.insert(_sharedRoute);
      _onSwitchToHistory();
      _sharedRoute = null;
    }
  }

  Future<void> addLifecycleIntentHandler({VoidCallback switchToHistory}) async {
    if (_onSwitchToHistory != null) return;

    _onSwitchToHistory = switchToHistory;
    WidgetsBinding.instance.addObserver(new LifecycleEventHandler(
        resumeCallBack: resume, suspendingCallBack: suspend));
    _appSuspended = true;
    await resume();
  }

  Future<HikingRoute> _getSharedData() async {
    String dataPath = await platform.invokeMethod("getSharedData");

    if (dataPath.isEmpty) return null;
    return await new ImportExportHandler().importRouteFromUri(dataPath);
  }
}
