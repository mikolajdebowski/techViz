import 'package:flutter/material.dart';
import 'package:techviz/components/vizElevatedButton.dart';

class VizExpandedButton extends StatelessWidget {
  VizExpandedButton({Key key, this.title, this.onTap, this.textColor, this.customWidget, this.flex = 1, this.customBackground})
      : super(key: key);

  final VoidCallback onTap;
  final String title;
  final Color textColor;
  final Widget customWidget;
  final int flex;
  final List<Color> customBackground;

  @override
  Widget build(BuildContext context) {
    return new Expanded(child: new VizElevatedButton(title: title, customWidget: customWidget, key: key, textColor: textColor, onTap: onTap, customBackground: customBackground), flex: flex);
  }
}
