import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class VizDialog {
  static Flushbar LoadingBar({String message = 'Wait...'}) {
    Flushbar fb = Flushbar(message: message, showProgressIndicator: true, animationDuration: Duration(milliseconds: 500));
    return fb;
  }

  static Future<bool> Alert(BuildContext context, String title, String message) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
            title: Text(title),
            content: Text(message),
            actions: actions,
          );
        });
  }
}


class VizDialogButton extends StatelessWidget{
  final String title;
  final Function action;
  final bool highlighted;

  VizDialogButton(this.title, this.action, {this.highlighted = true});

  @override
  Widget build(BuildContext context) {
    if(this.highlighted){
      return RaisedButton(
          child: Text(title, style: TextStyle(color: Colors.white)),
          onPressed: () {
            action();
          });
    }
    else{
      return FlatButton(
          child: Text(title),
          onPressed: () {
            action();
          });
    }


  }


}