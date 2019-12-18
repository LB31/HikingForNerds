import 'package:flutter/material.dart';
import 'package:hiking4nerds/styles.dart';

class RouteInfoList extends StatefulWidget {
  @override
  _RouteInfoListState createState() => _RouteInfoListState();
}

class _RouteInfoListState extends State<RouteInfoList> {

  List<RouteInfoTile> routelist = [
    RouteInfoTile(title: 'Berlin', date: '16.12.2019', ),
    RouteInfoTile(title: 'Hamburg', date: '12.12.2019', ),
    RouteInfoTile(title: 'Harz', date: '18.12.2019', ),
  ];

  void showPrev(index){
    RouteInfoTile instance = routelist[index];
    // reroute to home screen
    Navigator.pop(context, {
      'title': instance.title,
      'date': instance.date,
    });

  }

  @override
  Widget build(BuildContext context) {
    print('build func running');
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: htwGreen,
        title: Text('choose route to preview'),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: routelist.length,
        itemBuilder: (context, index){
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
            child: Card(
              child: ListTile(
                onTap: () {
                  showPrev(index);
                },
                title: Text(routelist[index].title),
                leading: CircleAvatar(
                  // backgroundImage: Icon(Icons.map),
                ),
              ),
            ),
          );
        },
      )
    );
  }
}

class RouteInfoTile {

  String title; // Route title i.e. Address
  String date; // Route date - created

  RouteInfoTile({ this.title, this.date });
}