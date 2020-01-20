import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  static final GlobalSettings _instance = GlobalSettings._internal();
  factory GlobalSettings() => _instance;

  bool safeHistory = true;
  bool useLocation = true;
  List<String> languageOptions = ["ENG", "DE"];
  String selectedLanguage;
  List<String> unitOptions = ["km", "mi"];
  String selectedUnit;
  double maximumRouteLength;

  GlobalSettings._internal();

  Future loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    safeHistory = (prefs.getBool('safeHistory') ?? true);
    useLocation = (prefs.getBool('useLocation') ?? true);
    selectedLanguage = (prefs.getString('selectedLanguage') ?? 'ENG');
    selectedUnit = (prefs.getString('selectedUnit') ?? 'km');
    maximumRouteLength = (prefs.getDouble('maximumRouteLength') ?? 5);
  }


}
