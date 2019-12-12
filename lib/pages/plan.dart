import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/navbar.dart';

class Plan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomNavigationBar: Navbar(),
    );
  }
}
