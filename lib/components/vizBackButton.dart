import 'package:flutter/material.dart';
import 'package:techviz/components/vizElevatedButton.dart';

class VizBackButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new VizElevatedButton(title: 'Back', onPressed: () {
      Navigator.maybePop(context);
    });
  }
}