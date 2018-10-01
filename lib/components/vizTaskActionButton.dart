import 'package:flutter/material.dart';

class VizTaskActionButton extends StatelessWidget{

  final String title;
  final List<Color> colors;
  final Function onTapCallback;
  final bool enabled;

  VizTaskActionButton(this.title, this.colors, {this.onTapCallback, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    var disabled = [Color(0xFF666666), Color(0xFFD3D3D3)];
    var defaultBg = [Color(0xFFB2C7CF),  Color(0xFFE4EDEF)];

    double fontSize = 16.0;
    if(this.title.length>10){
      fontSize = 12.0;
    }
    return Expanded(
        child: GestureDetector(
          onTap: (){
            if(enabled)
             onTapCallback();
          },
            child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: defaultBg,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          tileMode: TileMode.repeated)),
                  child: Center(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: enabled ? Colors.black : disabled[0]),
                      )),
                )),
            Container(
                width: 10.0,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: enabled ? colors : disabled,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        tileMode: TileMode.repeated)))
          ],
        )));
  }



}