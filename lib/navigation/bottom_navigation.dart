import 'package:flutter/material.dart';
import 'package:hiking4nerds/styles.dart';

enum AppSegment { setup, map, history, more }

final Map<AppSegment, String> segmentNames = {
  AppSegment.setup: 'Setup',
  AppSegment.map: 'Map',
  AppSegment.history: 'History',
  AppSegment.more: 'More',
};

final Map<AppSegment, IconData> segmentIcons = {
  AppSegment.setup: Icons.add_location,
  AppSegment.map: Icons.map,
  AppSegment.history: Icons.history,
  AppSegment.more: Icons.more_vert,
};

class BottomNavigation extends StatelessWidget {
  BottomNavigation({this.currentSegment, this.onSelectSegment});
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