import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techviz/config.dart';
import 'package:techviz/home.dart';
import 'package:techviz/loader.dart';
import 'package:techviz/login.dart';
import 'package:techviz/menu.dart';
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
      routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => Home(),
        '/menu': (BuildContext context) => Menu(),
        '/login': (BuildContext context) => Login(),
        '/config': (BuildContext context) => Config(),
        '/loader': (BuildContext context) => Loader(),
      },
    );
  }
}
