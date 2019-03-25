
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VizAlert{

  static Future<bool> Show(BuildContext ctx, String message){
    return showModalBottomSheet<bool>(
        context: ctx,
        builder: (BuildContext context) {
          return Center(
              child: Padding(
                padding: EdgeInsets.all(80.0),
                child: Text(message),
              ));
        });
  }
}