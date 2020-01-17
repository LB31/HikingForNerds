import 'package:shared_preferences/shared_preferences.dart';

import 'global_settings.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;

  LocalizationService._internal();

  String getLocalization({String english, String german}) {
    String currentLanguage = GlobalSettings().selectedLanguage;
    if (currentLanguage == "ENG") {
      return english;
    } else {
      return german;
    }
  }


}
