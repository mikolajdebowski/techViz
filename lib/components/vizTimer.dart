import 'package:flutter/material.dart';

class VizTimer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => VizTimerState();

}

class VizTimerState extends State<VizTimer>{
  String timeTakenStr = '00:00';

  @override
  Widget build(BuildContext context) {
    return Text(timeTakenStr, style: TextStyle(color: Colors.teal, fontSize: 45.0, fontFamily: 'DigitalClock'));
  }


//    var oneSec =  Duration(seconds: 1);
//    Timer.periodic(oneSec, (Timer t) {
//      DateTime dt = DateFormat('mm:ss').parse(timeTakenStr);
//      dt = dt.add(Duration(seconds: 1));
//      setState(() {
//        timeTakenStr = DateFormat('mm:ss').format(dt);
//      });
//    });

}

