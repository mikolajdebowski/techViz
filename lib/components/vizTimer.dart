import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VizTimer extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => VizTimerState();
  final DateTime timeStarted;
  VizTimer({this.timeStarted});
}

class VizTimerState extends State<VizTimer> {
  Timer _peridic;
  String _timerStr = '00:00';
  int _currentHash = 0;
  bool _containsHours = false;

  @override
  Widget build(BuildContext context) {
    if(widget.timeStarted != null){
      if(_currentHash != widget.hashCode) {
        _currentHash = widget.hashCode;

        if (_peridic != null) {
          _peridic.cancel();
        }

        _peridic = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
          var now = DateTime.now().toUtc();

          if(widget == null || widget.timeStarted == null){
            t.cancel();

            setState(() {
              _containsHours = false;
              _timerStr = '00:00';
            });

            return;
          }

          var _difference = now.difference(widget.timeStarted);


          var hours = (_difference.inHours);
          var mins = (_difference.inMinutes - (_difference.inHours * 60));
          var secs = (_difference.inSeconds - (_difference.inMinutes * 60));

          String format = 'mm:ss';
          String timeStr = '${mins}:${secs}';
          if (hours > 0) {
            format = 'H:mm:ss';
            timeStr = '${hours}:${mins}:${secs}';
          }

          DateTime dt = DateFormat(format).parse(timeStr);
          dt = dt.add(Duration(seconds: 1));
          setState(() {
            _containsHours = hours>0;
            _timerStr = DateFormat(format).format(dt);
          });
        });
      }
    }

    Color clockColor = Colors.grey;
    if(widget.timeStarted!=null)
        clockColor =  Colors.teal;

    double fontSize = 35.0;
    if(_containsHours){
      fontSize = 25.0;
    }

    return Text( _timerStr, style: TextStyle(color: clockColor, fontSize: fontSize, fontFamily: 'DigitalClock'));
  }
}

