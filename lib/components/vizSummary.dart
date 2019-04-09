import 'package:flutter/material.dart';
import 'package:techviz/components/vizSummaryHeader.dart';

class VizSummary extends StatefulWidget {
  final VizSummaryHeader header;
  final Widget list;

  const VizSummary({Key key, this.header, this.list}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizSummaryState();
}

class VizSummaryState extends State<VizSummary> {
  bool collapsed = true;

  @override
  Widget build(BuildContext context) {
    BoxDecoration boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Color(0xFFFFFFFF)),
        gradient: LinearGradient(
            colors: [Color(0xFF81919D), Color(0xFFAAB7BD)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated));

    Container container;

    bool mustExpand = widget.list!=null;

    Widget inner = widget.header!=null? widget.header : Center(child: Padding(child: CircularProgressIndicator(), padding: EdgeInsets.all(10.0),));
    Widget expandedChild = widget.list!=null ? widget.list : Center(child: CircularProgressIndicator());

    if(mustExpand==false) {
      container = Container(
        decoration: boxDecoration,
        child: inner,
      );
    }
    else{
      container = Container(
        decoration: boxDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[inner, Container(
            height: 100,
            child: expandedChild,
          )],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: 5, top: 5, right: 5),
      child: GestureDetector(
        child: container,
        onTap: (){
          setState(() {
            collapsed = !collapsed;
          });
        },
      ),
    );
  }
}