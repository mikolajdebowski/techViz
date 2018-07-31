import 'package:flutter/material.dart';

class VizButton extends StatelessWidget {
  VizButton(this.title,
    {Key key,
    this.onTap,
    this.flex = 1,
    this.iconName,
    this.highlighted = false})
      : super(key: key);

  final VoidCallback onTap;
  final String title;
  final String iconName;
  final int flex;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    var defaultBg = [Color(0xFFebf0f2), Color(0xFFbdccd4)];
    var highlightBg = [Color(0xFF96c93f), Color(0xFF09a593)];

    var txtDefaultColor = Color(0xFF636f7e);
    var txtHighlightColor = Colors.white;

    BoxDecoration bg = BoxDecoration(
        border: Border.all(color: highlighted? Colors.transparent : Colors.white),
        gradient: LinearGradient(
            colors: (highlighted ? highlightBg : defaultBg),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(5.0));

    Text innerText = Text(title, style: TextStyle(color: (highlighted?txtHighlightColor:txtDefaultColor), fontSize: 20.0, fontWeight: FontWeight.w500));

    Widget innerWidget = null;
    if(iconName==null){
      innerWidget = innerText;
    }
    else{
      Image icon = Image(image: AssetImage('assets/images/${iconName}'), height: 30.0,);
      innerWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[icon,Padding(child: innerText, padding: EdgeInsets.only(left: 10.0))],
      );
    }

    return Flexible(
      fit: FlexFit.tight,
      flex: flex,
      child: GestureDetector(
          onTap: onTap,
          child: Container(
              margin: EdgeInsets.all(2.0),
              constraints: BoxConstraints.expand(),
              decoration: bg,
              child: Center(child: innerWidget)
          ),
        )
    );

  }



}

