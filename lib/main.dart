import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techviz/splash.dart';


void main() => runApp(TechVizApp());

class TechVizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechViz',
      home: Splash(),
    );
  }
}
