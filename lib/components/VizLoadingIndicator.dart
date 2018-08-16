import 'package:flutter/material.dart';

class VizLoadingIndicator extends StatelessWidget {

  final String message;
  final bool isLoading;

  VizLoadingIndicator({this.message = 'Loading', this.isLoading = false});
  @override
  Widget build(BuildContext context) {

    List<Widget> widgetList = List<Widget>();

    if(isLoading){
      widgetList.add(
          Center(
            child: Container(
              color: Color(0xDD000000),
              constraints: BoxConstraints(minWidth: 300.0),
              child: Padding(padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(padding: EdgeInsets.only(left: 20.0), child: Text(message, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),)
                ],
              ),),
            ),
          )
      );
    }

    return Stack(
      children: widgetList,
    );
  }
}
