import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class VizDialog {
  static Flushbar LoadingBar({String message = 'Wait...'}) {
    Flushbar fb = Flushbar(message: message, showProgressIndicator: true, animationDuration: Duration(milliseconds: 500));
    return fb;
  }

  static RoundedRectangleBorder defaultBorder = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)));

  static Future<bool> Alert(BuildContext context, String title, String message) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: defaultBorder,
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

  static Future<bool> Confirm(Key key, BuildContext context, String title, String message, {List<VizDialogButton> actions}) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            key: key,
            shape: defaultBorder,
            title: Text(title),
            content: Text(message),
            actions: actions,
          );
        });
  }
}

class VizDialogButton extends StatelessWidget {
  final String title;
  final Function action;
  final bool highlighted;
  final bool processing;
  final bool disabled;

  const VizDialogButton(this.title, this.action, {this.highlighted = true, this.processing = false, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    if (highlighted) {
      return RaisedButton(
          elevation: 5,
          child: processing ? Center(child: SizedBox(
            child: CircularProgressIndicator(),
            height: 25.0,
            width: 25.0,
          )) : Text(title, style: TextStyle(color: Colors.white)),
          onPressed: () {
            if (!disabled)
              action();
          });
    }
    else {
      return FlatButton(
          child: Text(title, style: TextStyle(color: disabled ? Colors.grey : Colors.black)),
          onPressed: () {
            if (!disabled)
              action();
          });
    }
  }
}