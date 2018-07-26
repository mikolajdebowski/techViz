import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VizTimer extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => VizTimerState();

  final String timeStarted;
  VizTimer({this.timeStarted}){
    print(this.timeStarted);
  }
}

class VizTimerState extends State<VizTimer> {
  String _timerStrStarted = '00:00';
  String _timerStr = '00:00';
  Timer _peridic = null;

  @override
  Widget build(BuildContext context) {
    if(widget.timeStarted != null){
      if(_peridic==null || _timerStrStarted != widget.timeStarted){
        setState(() {
          _timerStrStarted = widget.timeStarted;
          _timerStr = widget.timeStarted;
        });

        if(_peridic!=null){
          _peridic.cancel();
        }
        _peridic = Timer.periodic(Duration(seconds: 1), (Timer t) {
          DateTime dt = DateFormat('mm:ss').parse(_timerStr);
          dt = dt.add(Duration(seconds: 1));
          setState(() {
            _timerStr = DateFormat('mm:ss').format(dt);
          });
        });
      }
    }
    return Text( _timerStr, style: TextStyle(color: Colors.teal, fontSize: 35.0, fontFamily: 'DigitalClock'));
  }
}

