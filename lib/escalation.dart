import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Escalation {
  static Future<bool> show(BuildContext _context) {
    Completer<bool> _completer = Completer<bool>();

    Dialog dialog = Dialog(
      child: innerBuild(_context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
    );

    showDialog<bool>(
        barrierDismissible: false,
        context: _context,
        builder: (BuildContext context) {
          return dialog;
        }).then((bool result) {
      _completer.complete(result);
    });

    return _completer.future;
  }

  static Widget innerBuild(BuildContext context) {
    double _width = MediaQuery.of(context).size.width / 100 * 80;

    Container container = Container(
        width: _width,
        decoration: BoxDecoration(shape: BoxShape.rectangle),
        child: SingleChildScrollView(
            child: Form(
                child: Column(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Text('Escalate a task'),
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Stack(
                    children: <Widget>[
                      Align(alignment: Alignment.centerLeft ,child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          "Cancel",
                        ),
                      )),
                      Align(alignment: Alignment.centerRight ,child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text(
                          "Next",
                          style: TextStyle(color: Colors.green),
                        ),
                      ))
                    ],
                  )
                ]))));

    return container;
  }
}
