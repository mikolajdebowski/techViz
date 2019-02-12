
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VizAlert{

  static void Show(BuildContext ctx, String message){
    showModalBottomSheet<String>(
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