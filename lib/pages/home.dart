import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/mapwidget.dart';
import 'package:hiking4nerds/components/navbar.dart';
import 'package:hiking4nerds/components/shareroute.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hiking 4 Nerds'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: <Widget>[
          MapWidget(isStatic: false),
          //TODO: remove mock button
          Align(
            alignment: Alignment.bottomRight,
            child: RawMaterialButton(
              onPressed: () {
                HikingRoute mockRoute = HikingRoute([
                  Node(0, 52.510318, 13.4085592),
                  Node(1, 52.5102903, 13.4084606),
                  Node(2, 52.5101514, 13.4081806)
                ], 2);

                showDialog(
                    context: context,
                    builder: (BuildContext context) => ShareRoute(
                          route: mockRoute,
                        ));
              },
              child: Icon(
                Icons.share,
                color: Colors.black,
                size: 36.0,
              ),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: htwGreen,
              padding: const EdgeInsets.all(5.0),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.find_replace),
        backgroundColor: htwGreen,
        elevation: 2.0,
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
