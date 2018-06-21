import 'package:flutter/material.dart';

class AttendantHome extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new AttendantHomeState();
}


class AttendantHomeState extends State<AttendantHome>{
  @override
  Widget build(BuildContext context) {
    LinearGradient gradientHeader = LinearGradient(
        colors: [const Color(0xFF4D4D4D), const Color(0xFF000000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.repeated);

    BoxDecoration boxDecorationHeader = BoxDecoration(
        gradient: gradientHeader);


    LinearGradient gradientBody = LinearGradient(
        colors: [const Color(0xFF586676), const Color(0xFF8B9EA7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.repeated);

    BoxDecoration boxDecorationBody= BoxDecoration(
        gradient: gradientBody);


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 100.0,
          decoration: boxDecorationHeader,
        ),
        Expanded(
          child: Container(
            decoration: boxDecorationBody,
          ),
        )
      ],
    );
  }

}