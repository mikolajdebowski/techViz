
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VizAlert{

  static Future<bool> Show(BuildContext ctx, String message){
    return showModalBottomSheet<bool>(
        context: ctx,
        builder: (BuildContext context) {
          return Center(
              child: Padding(
                child: Text(message, maxLines: 3),
                padding: EdgeInsets.all(15),
              )
          );
        });
  }
}