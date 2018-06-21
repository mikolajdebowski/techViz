import 'package:flutter/material.dart';
import 'package:techviz/home.dart';

void main() => runApp(TechVizApp());

class TechVizApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechViz',
      home: Home(),
    );
  }


}
