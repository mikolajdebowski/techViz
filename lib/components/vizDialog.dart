import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class VizDialog {
  static Flushbar LoadingBar({String message = 'Wait...'}) {
    Flushbar fb = Flushbar(
        message: message,
        showProgressIndicator: true,
        animationDuration: Duration(milliseconds: 500));
    return fb;
  }

  static Future<bool> Alert(
      BuildContext context, String title, String message) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  })
            ],
          );
        });
  }
}
