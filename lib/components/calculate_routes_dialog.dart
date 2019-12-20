import 'package:flutter/material.dart';

class CalculatingRoutesDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Center(child: CircularProgressIndicator()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              // TODO add localization
              child: Center(child: Text("Calculating Route...")),
            ),
          ],
        ),
      ),
    ));
  }
}
