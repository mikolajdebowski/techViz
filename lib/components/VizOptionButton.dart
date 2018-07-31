import 'package:flutter/material.dart';

class VizOptionButton extends StatelessWidget {
  VizOptionButton(this.title,
      {Key key,
        this.onTap,
        this.flex = 1,
        this.selected = false,
        this.iconName})
      : super(key: key);

  final VoidCallback onTap;
  final String title;
  final bool selected;
  final String iconName;
  final int flex;

  @override
  Widget build(BuildContext context) {
    BoxDecoration bg = BoxDecoration(
        color: Colors.grey,
        gradient: LinearGradient(
            colors: [Color(0xFFbdccd4), Color(0xFFebf0f2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(4.0));

    Text innerText = Text(title, style: TextStyle(color: Color(0xFF474f5b), fontSize: 16.0));

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
        child: Padding(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
                constraints: BoxConstraints.expand(),
                decoration: bg,
                child: Center(child: innerWidget)
            ),
          ),
          padding: EdgeInsets.all(5.0),
        )
    );

  }
}

