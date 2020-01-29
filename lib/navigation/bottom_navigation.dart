import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/global_settings.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/styles.dart';

enum AppSegment { setup, map, history, more }

final Map<AppSegment, IconData> segmentIcons = {
  AppSegment.setup: Icons.add_location,
  AppSegment.map: Icons.map,
  AppSegment.history: Icons.history,
  AppSegment.more: Icons.more,
};

class BottomNavigation extends StatelessWidget {
  final Map<AppSegment, String> segmentNames = {
    AppSegment.setup: LocalizationService()
        .getLocalization(english: "Setup", german: "Planung"),
    AppSegment.map:
        LocalizationService().getLocalization(english: "Map", german: "Karte"),
    AppSegment.history: LocalizationService()
        .getLocalization(english: "History", german: "Verlauf"),
    AppSegment.more:
        LocalizationService().getLocalization(english: "More", german: "Mehr"),
  };

  BottomNavigation({this.currentSegment, this.onSelectSegment}) {
    GlobalSettings().langaugeChanged = () { 
      // Small hack to update the navigation's langauge
      onSelectSegment(AppSegment.values[0]);
      onSelectSegment(AppSegment.more);
    };
  }

  final AppSegment currentSegment;
  final ValueChanged<AppSegment> onSelectSegment;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(selectedSegment: AppSegment.setup),
        _buildItem(selectedSegment: AppSegment.map),
        _buildItem(selectedSegment: AppSegment.history),
        _buildItem(selectedSegment: AppSegment.more),
      ],
      onTap: (index) => onSelectSegment(
        AppSegment.values[index],
      ),
    );
  }

  BottomNavigationBarItem _buildItem({AppSegment selectedSegment}) {
    String text = segmentNames[selectedSegment];
    return BottomNavigationBarItem(
      icon: Icon(
        segmentIcons[selectedSegment],
        color: currentSegment == selectedSegment ? htwGreen : htwGrey,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: currentSegment == selectedSegment ? htwGreen : htwGrey,
        ),
      ),
    );
  }
}
