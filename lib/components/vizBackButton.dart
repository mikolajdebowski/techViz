import 'package:flutter/material.dart';
import 'package:techviz/components/vizExpandedButton.dart';

class VizBackButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new VizExpandedButton(title: 'Back', onTap: () {
      Navigator.maybePop(context);
    });
  }
}