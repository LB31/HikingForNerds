import 'dart:ui';


class PoiCategory {
  static List<PoiCategory> categories = [
    PoiCategory(
        id: 'information',
        nameEng: "Information",
        nameGer: "Information",
        symbolPath: "assets/img/symbols/information.png",
        color: const Color(0xff346e43)),
    PoiCategory(
        id: 'attraction',
        nameEng: "Attraction",
        nameGer: "Attraktion",
        symbolPath: "assets/img/symbols/attraction.png",
        color: const Color(0xff006565)),
    PoiCategory(
        id: 'viewpoint',
        nameEng: "Viewpoint",
        nameGer: "Aussichtspunkt",
        symbolPath: "assets/img/symbols/viewpoint.png",
        color: const Color(0xff60407d)),
    PoiCategory(
        id: 'artwork',
        nameEng: "Artwork",
        nameGer: "Kunstwerk",
        symbolPath: "assets/img/symbols/artwork.png",
        color: const Color(0xff7a4060)),
    PoiCategory(
        id: 'museum',
        nameEng: "Museum",
        nameGer: "Museum",
        symbolPath: "assets/img/symbols/museum.png",
        color: const Color(0xff733c3f)),
    PoiCategory(
        id: 'alpine_hut',
        nameEng: "Alpine Hut",
        nameGer: "Almhütte",
        symbolPath: "assets/img/symbols/alpine_hut.png",
        color: const Color(0xff704e36)),
    PoiCategory(
        id: 'hunting_stand',
        nameEng: "Hunting Stand",
        nameGer: "Jagdhütte",
        symbolPath: "assets/img/symbols/hunting_stand.png",
        color: const Color(0xff827d1e)),
    PoiCategory(
        id: 'camp_pitch',
        nameEng: "Camp Pitch",
        nameGer: "Zeltplatz",
        symbolPath: "assets/img/symbols/camp_pitch.png",
        color: const Color(0xff12635f)),
    PoiCategory(
        id: 'bench',
        nameEng: "Bench",
        nameGer: "Sitzbank",
        symbolPath: "assets/img/symbols/bench.png",
        color: const Color(0xff373795)),
    PoiCategory(
        id: 'restaurant',
        nameEng: "Restaurant",
        nameGer: "Restaurant",
        symbolPath: "assets/img/symbols/restaurant.png",
        color: const Color(0xffa4252a)),
    PoiCategory(
        id: 'cafe',
        nameEng: "Cafe",
        nameGer: "Café",
        symbolPath: "assets/img/symbols/cafe.png",
        color: const Color(0xff246e40)),
    PoiCategory(
        id: 'fast_food',
        nameEng: "Fast Food",
        nameGer: "Fast Food",
        symbolPath: "assets/img/symbols/fast_food.png",
        color: const Color(0xffdca34d)),
    PoiCategory(
        id: 'bar',
        nameEng: "Bar",
        nameGer: "Bar",
        symbolPath: "assets/img/symbols/bar.png",
        color: const Color(0xff405e1f)),
    PoiCategory(
        id: 'toilets',
        nameEng: "Toilet",
        nameGer: "Toilette",
        symbolPath: "assets/img/symbols/toilets.png",
        color: const Color(0xff832644)),
    PoiCategory(
        id: 'drinking_water',
        nameEng: "Drinking Water",
        nameGer: "Trinkwasser",
        symbolPath: "assets/img/symbols/drinking_water.png",
        color: const Color(0xff553f70)),
    PoiCategory(
        id: 'fountain',
        nameEng: "Fountain",
        nameGer: "Springbrunnen",
        symbolPath: "assets/img/symbols/fountain.png",
        color: const Color(0xff733667))
  ];

  String id;
  String nameEng;
  String nameGer;
  String symbolPath;
  Color color;

  // https://stackoverflow.com/a/50081214
  String colorAsHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${color.red.toRadixString(16).padLeft(2, '0')}'
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      '${color.blue.toRadixString(16).padLeft(2, '0')}';

  PoiCategory(
      {this.id, this.nameEng, this.nameGer, this.symbolPath, this.color});
}
