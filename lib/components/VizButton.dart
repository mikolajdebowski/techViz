import 'package:flutter/material.dart';

class VizButton extends StatelessWidget {
  VizButton(
    {Key key,
    this.title,
    this.onTap,
    this.flex = 1,
    this.iconName,
    this.highlighted = false,
    this.enabled = true,
    this.customWidget})
      : super(key: key);

  final VoidCallback onTap;
  final String title;
  final String iconName;
  final int flex;
  final bool highlighted;
  final Widget customWidget;
  final bool enabled;


  @override
  Widget build(BuildContext context) {
    var txtDefaultColor = Color(0xFF636f7e);
    var txtHighlightColor = Colors.white;


    Widget innerWidget = null;
    if(customWidget != null){
      innerWidget = customWidget;
    }
    else {
      Text innerText = Text(title, style: TextStyle(color: (highlighted?txtHighlightColor:txtDefaultColor), fontSize: 20.0, fontWeight: FontWeight.w500));
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
    }

    return Flexible(
      fit: FlexFit.tight,
      flex: flex,
      child: GestureDetector(
          onTap: onTap,
          child: Container(
              margin: EdgeInsets.all(3.0),
              constraints: BoxConstraints.expand(),
              decoration: DefaultBoxDecoration,
              child: Center(child: innerWidget)
          ),
        )
    );
  }


  BoxDecoration get DefaultBoxDecoration{
    var defaultBg = [Color(0xFFebf0f2), Color(0xFFbdccd4)];
    var highlightBg = [Color(0xFF96c93f), Color(0xFF09a593)];
    var disabledBg = [Color(0xFFD3D3D3), Color(0xFFD3D3D3)];

    return BoxDecoration(
        boxShadow: [BoxShadow(color: Color(0xAA000000), offset: Offset(2.0, 2.0), blurRadius: 2.0)],
        border: Border.all(color: highlighted? Colors.transparent : Colors.white),
        gradient: LinearGradient(
            colors: (enabled == false ? disabledBg: (highlighted ? highlightBg : defaultBg)),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(5.0));
  }



}

