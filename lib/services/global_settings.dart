class GlobalSettings {
  static final GlobalSettings _instance = GlobalSettings._internal();
  factory GlobalSettings() => _instance;

  bool safeHistory = true;
  bool useLocation = true;
  
  GlobalSettings._internal() {
    // init things inside this
  }
  
  // Methods, variables ...
}