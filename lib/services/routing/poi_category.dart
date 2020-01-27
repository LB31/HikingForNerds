import 'dart:ui';

import '../localization_service.dart';

class PoiCategory {
  static List<PoiCategory> categories = [
    PoiCategory(id: 'information',
        name: LocalizationService().getLocalization(
            english: "Information",
            german: "Information"),
        symbolPath: "assets/img/symbols/information.png",
        color: const Color(0xff346e43)),
    PoiCategory(id: 'attraction',
        name: LocalizationService().getLocalization(
            english: "Attraction",
            german: "Attraktion"),
        symbolPath: "assets/img/symbols/attraction.png",
        color: const Color(0xff006565)),
    PoiCategory(id: 'viewpoint',
        name: LocalizationService().getLocalization(
            english: "Viewpoint",
            german: "Aussichtspunkt"),
        symbolPath: "assets/img/symbols/viewpoint.png",
        color: const Color(0xff60407d)),
    PoiCategory(id: 'artwork',
        name: LocalizationService().getLocalization(
            english: "Artwork",
            german: "Kunstwerk"),
        symbolPath: "assets/img/symbols/artwork.png",
        color: const Color(0xff7a4060)),
    PoiCategory(id: 'museum',
        name: LocalizationService().getLocalization(
            english: "Museum",
            german: "Museum"),
        symbolPath: "assets/img/symbols/museum.png",
        color: const Color(0xff733c3f)),
    PoiCategory(id: 'alpine_hut',
        name: LocalizationService().getLocalization(
            english: "Alpine Hut",
            german: "Almhütte"),
        symbolPath: "assets/img/symbols/alpine_hut.png",
        color: const Color(0xff704e36)),
    PoiCategory(id: 'hunting_stand',
        name: LocalizationService().getLocalization(
            english: "Hunting Stand",
            german: "Jagdhütte"),
        symbolPath: "assets/img/symbols/hunting_stand.png",
        color: const Color(0xff827d1e)),
    PoiCategory(id: 'camp_pitch',
        name: LocalizationService().getLocalization(
            english: "Camp Pitch",
            german: "Zeltplatz"),
        symbolPath: "assets/img/symbols/camp_pitch.png",
        color: const Color(0xff12635f)),
    PoiCategory(id: 'camp_pitch',
        name: LocalizationService().getLocalization(
            english: "Bench",
            german: "Sitzbank"),
        symbolPath: "assets/img/symbols/bench.png",
        color: const Color(0xff373795)),
    PoiCategory(id: 'restaurant',
        name: LocalizationService().getLocalization(
            english: "Restaurant",
            german: "Restaurant"),
        symbolPath: "assets/img/symbols/restaurant.png",
        color: const Color(0xffa4252a)),
    PoiCategory(id: 'cafe',
        name: LocalizationService().getLocalization(
            english: "Cafe",
            german: "Café"),
        symbolPath: "assets/img/symbols/cafe.png",
        color: const Color(0xff246e40)),
    PoiCategory(id: 'fast_food',
        name: LocalizationService().getLocalization(
            english: "Fast Food",
            german: "Fast Food"),
        symbolPath: "assets/img/symbols/fast_food.png",
        color: const Color(0xffdca34d)),
    PoiCategory(id: 'bar',
        name: LocalizationService().getLocalization(
            english: "Bar",
            german: "Bar"),
        symbolPath: "assets/img/symbols/bar.png",
        color: const Color(0xff405e1f)),
    PoiCategory(id: 'toilets',
        name: LocalizationService().getLocalization(
            english: "Toilet",
            german: "Toilette"),
        symbolPath: "assets/img/symbols/toilets.png",
        color: const Color(0xff832644)),
    PoiCategory(id: 'drinking_water',
        name: LocalizationService().getLocalization(
            english: "Drinking Water",
            german: "Trinkwasser"),
        symbolPath: "assets/img/symbols/drinking_water.png",
        color: const Color(0xff553f70)),
    PoiCategory(id: 'fountain',
        name: LocalizationService().getLocalization(
            english: "Fountain",
            german: "Springbrunnen"),
        symbolPath: "assets/img/symbols/fountain.png",
        color: const Color(0xff733667))
  ];

  String id;
  String name;
  String symbolPath;
  Color color;

  // https://stackoverflow.com/a/50081214
  String colorAsHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${color.red.toRadixString(16).padLeft(2, '0')}'
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      '${color.blue.toRadixString(16).padLeft(2, '0')}';

  PoiCategory({this.id, this.name, this.symbolPath, this.color});
}