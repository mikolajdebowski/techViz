import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class VizDialog {


  static Flushbar LoadingBar({String message = 'Wait...'}) {
    Flushbar fb = Flushbar();
    if (message != null && message.length > 0)
      fb.message = message;
    fb.showProgressIndicator = true;
    fb.animationDuration = Duration(milliseconds: 500);
    return fb;
  }


  static void Alert(BuildContext context, String title, String message) {
    showDialog<void>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(child: Text('Close'), onPressed: () {
            Navigator.of(context).pop();
          })
        ],
      );
    });
  }
}


