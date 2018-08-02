import 'package:flutter/material.dart';

class VizRainbow extends StatelessWidget {

  final colors = <Color>[
    Color(0xFFd6de27),
    Color(0xFF96c93f),
    Color(0xFF09a593),
    Color(0xFF0c7dc2),
    Color(0xFF564992),
    Color(0xFFea1c42),
    Color(0xFFf69320),
    Color(0xFFfedd00)
  ];


  @override
  Widget build(BuildContext context) {

    var rainbow = Container(
      height: 10.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight, // 10% of the width, so there are ten blinds.
          colors: colors,
        ),
      ),
    );

    return rainbow;

  }
}

