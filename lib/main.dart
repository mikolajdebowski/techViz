import 'package:flutter/material.dart';
import 'package:techviz/home.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'TechViz',
      home: new Home(),
    );
  }
}
