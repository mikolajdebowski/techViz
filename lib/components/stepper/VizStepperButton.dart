import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VizStepperButton extends StatelessWidget {

  final GestureTapCallback onTap;
  final String title;
  final bool isActive;

  VizStepperButton({Key key, this.onTap, this.title, this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 30.0;

    return GestureDetector(
      onTap: onTap,
      child:  Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.white70,
          shape: BoxShape.circle
        ),
        child: Center(child: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.black),)),
      ),
    );
  }
}