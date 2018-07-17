import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VizTimer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => VizTimerState();

  final String currentTime;
  VizTimer({this.currentTime}){

  }
}

class VizTimerState extends State<VizTimer>{
  String currentTimeLocal = '00:00';


  @override
  void initState() {
    // TODO: implement initState

//    Timer.periodic(Duration(seconds: 1), (Timer t) {
//      DateTime dt = DateFormat('mm:ss').parse(currentTimeLocal);
//      dt = dt.add(Duration(seconds: 1));
//      setState(() {
//        currentTimeLocal = DateFormat('mm:ss').format(dt);
//      });
//    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(currentTimeLocal, style: TextStyle(color: Colors.teal, fontSize: 35.0, fontFamily: 'DigitalClock'));
  }


}

