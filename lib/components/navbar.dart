import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<String> options = ['/plan', '/routesetup', '/settings'];
  static String currentRoute = '/';

  void _onItemTapped(int index) {
    currentRoute = ModalRoute.of(context).settings.name;
    if(currentRoute != options[index]) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
      Navigator.pushNamed(context, options[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
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
          )],
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.grey,
      );
  }
}