import 'package:flutter/material.dart';
import 'package:techviz/components/vizElevated.dart';

class VizBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: VizElevated(
            title: 'Back',
            onTap: () {
              Navigator.maybePop(context);
            }));
  }
}
