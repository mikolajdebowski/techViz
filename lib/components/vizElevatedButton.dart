import 'package:flutter/material.dart';

class VizElevatedButton extends StatelessWidget {
  VizElevatedButton({Key key, this.title, this.onPressed, this.textColor, this.customWidget, this.flex = 1})
      : super(key: key);

  final VoidCallback onPressed;
  final String title;
  final Color textColor;
  final Widget customWidget;
  final int flex;

  @override
  Widget build(BuildContext context) {

    const TextStyle defaultTextStyle = const TextStyle(
        color: Colors.white,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 22.0);


    var titleWidget;
    if(this.customWidget != null){
      titleWidget = this.customWidget;
    }
    else {
      if(this.textColor != null){
        titleWidget = new Text(title, textAlign: TextAlign.center, style: defaultTextStyle.copyWith(color: textColor));
      }
      else{
        titleWidget = new Text(title, textAlign: TextAlign.center, style: defaultTextStyle);
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
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[titleWidget],
      ),
    );

    var tapper = new GestureDetector(
      child: container,
      onTap: onPressed,
    );

    return new Expanded(child: tapper, flex: flex);
  }
}
