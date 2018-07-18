import 'package:flutter/material.dart';

class VizTaskActionButton extends StatelessWidget{

  final String title;
  final List<Color> colors;
  final Function onTapCallback;

  VizTaskActionButton(this.title, this.colors, {this.onTapCallback});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
          onTap: (){
            onTapCallback();
          },
            child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [ Color(0xFFB2C7CF),  Color(0xFFE4EDEF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          tileMode: TileMode.repeated)),
                  child: Center(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                      )),
                )),
            Container(
                width: 10.0,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        tileMode: TileMode.repeated)))
          ],
        )));
  }



}