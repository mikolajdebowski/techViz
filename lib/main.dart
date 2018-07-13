import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techviz/home.dart';
import 'package:techviz/loader.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

void main() => runApp(TechVizApp());

class TechVizApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'TechViz',
      home: Loader(),
    );
  }
}
