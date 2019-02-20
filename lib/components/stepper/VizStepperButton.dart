import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VizStepperButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String title;

  const VizStepperButton({Key key, this.onTap, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 30.0;

    return InkResponse(
      onTap: onTap,
      child:  Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(title)),
      ),
    );
  }
}