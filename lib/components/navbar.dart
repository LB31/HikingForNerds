import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<String> options = ['/plan', '/route', '/settings'];
  static String currentRoute = '/';

  void _onItemTapped(int index) {
    currentRoute = ModalRoute.of(context).settings.name;
    if (currentRoute != options[index]) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
      Navigator.pushNamed(context, options[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.help_outline),
          title: Text('Plan'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.find_replace),
          title: Text('Route'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text('Settings'),
        )
      ],
      onTap: _onItemTapped,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.grey,
    );
  }
}
