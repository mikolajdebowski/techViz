import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class VizTaskActionButton extends StatelessWidget {
  final String title;
  final Color color;
  final Function onTapCallback;
  final bool enabled;
  final String icon;
  final double height;

  const VizTaskActionButton(this.title, this.color, {this.onTapCallback, this.enabled = true, this.icon, this.height = 70});

  @override
  Widget build(BuildContext context) {
    Color disabledColor = Color(0xFFAAAAAA);
    BoxDecoration boxDecoration = BoxDecoration(borderRadius: BorderRadius.circular(6.0), border: Border.all(color: Colors.white), color: enabled ? color : disabledColor);
    AutoSizeText titleWidget = AutoSizeText(title,style: TextStyle(fontSize: height == 70 ? 18 : 26, color: enabled ? Colors.white : Colors.white30));

    Widget centerWidget = icon==null ? titleWidget :  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ImageIcon(AssetImage(icon), size: height/3, color: enabled ? Colors.white : Colors.white30),
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: titleWidget,
        )
      ],
    );

    return GestureDetector(
        onTap: () {
          if (enabled) onTapCallback();
        },
        child: Container(
            decoration: boxDecoration,
            constraints: BoxConstraints.expand(height: height),
            child: Center(
              child: centerWidget,
            )));
  }
}
