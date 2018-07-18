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
  String _lastTimeStarted = '00:00';
  String _timerStr = '00:00';
  Timer _peridic = null;

  @override
  Widget build(BuildContext context) {
    if(_peridic==null || _lastTimeStarted != widget.timeStarted){
      setState(() {
        _lastTimeStarted = widget.timeStarted;
        _timerStr = '00:00';

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
      });

    }
    return Text( _timerStr, style: TextStyle(color: Colors.teal, fontSize: 35.0, fontFamily: 'DigitalClock'));
  }
}

