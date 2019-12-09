import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/hikingmapbox.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

    static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

    void _onItemTapped(int index) {
      List<String> options = ['/help', '/routesetup', '/settings'];
      Navigator.pushNamed(context, options[index]);
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Hiking 4 Nerds'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: <Widget>[
          MapWidget(),
      
        ]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            title: Text('Help'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.find_replace),
            title: Text('Route'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
        onTap: _onItemTapped,
        currentIndex: 1,
      ),
    );
  }
}