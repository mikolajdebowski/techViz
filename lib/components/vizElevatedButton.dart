import 'package:flutter/material.dart';

class VizElevatedButton extends StatelessWidget {
  VizElevatedButton({Key key, this.title, this.onTap, this.textColor, this.customWidget}) : super(key: key);

  final VoidCallback onTap;
  final String title;
  final Color textColor;
  final Widget customWidget;

  @override
  Widget build(BuildContext context) {

    const TextStyle defaultTextStyle = const TextStyle(
        color: Colors.white,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 22.0);


    var innerWidget;
    if(this.customWidget != null){
      innerWidget = this.customWidget;
    }
    else {
      if(this.textColor != null){
        innerWidget = new Text(title, textAlign: TextAlign.center, style: defaultTextStyle.copyWith(color: textColor));
      }
      else{
        innerWidget = new Text(title, textAlign: TextAlign.center, style: defaultTextStyle);
      }
    }

    var container = new Container(
      margin: const EdgeInsets.all(2.0),
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(4.0),
          border: new Border.all(color: const Color(0xFF555555)),
          gradient: new LinearGradient(
              colors: [
                const Color(0xFF252930),
                const Color(0xFF1a1b1f),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.repeated)),
      child: new Center(
        child: innerWidget,
      ),
    );

    var tapper = new GestureDetector(
      child: container,
      onTap: onTap,
    );

    return tapper;
  }
}
