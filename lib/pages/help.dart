import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/help_data.dart';

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {

  List helpdata = [
    HelpData(
      title: 'Set starting point', 
      text: 'There are two ways to define the starting point of your trip. 1. Tap on and hold the desired starting location to set up a marker. 2. If there is no marker set, than the route will be calculated starting from your current position.'),
    HelpData(
      title: 'Set route parameters and find route', 
      text: 'Go to Menu and select "Find Route". Select the desired route length and other parametes. Finally click "Find Route". This will redirect you to the navigation screen and display the calculated route')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        itemCount: helpdata.length,
        itemBuilder: (context, index){
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
            child: Card(
              child: ListTile(
                onTap: () {},
                title: Text(helpdata[index].title),
                subtitle: Text(helpdata[index].text),
              ),
            ),
          );
        },
      )
    );
  }
}
