class NoRoutesFoundException implements Exception{
  @override
  String toString() {
    return "No routes found to given parameters.";
  }
}