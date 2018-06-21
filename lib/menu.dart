import 'dart:async';

import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:techviz/components/charts/vizPieChart.dart';
import 'package:techviz/components/charts/vizBarChart.dart';

class Menu extends StatefulWidget {
  Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: ActionBar(title: 'Menu'),
        body: Center(child: Text('Menu', style: TextStyle(color: Colors.white))));
  }
}
