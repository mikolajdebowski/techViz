import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/vizListViewRow.dart';
import 'package:techviz/model/dataEntry.dart';

typedef SwipeActionCallback = void Function(dynamic tag);

class SwipeAction{
  final String headerTitle;
  final String title;
  final SwipeActionCallback callback;

  SwipeAction(this.title, this.headerTitle, this.callback);
}

class VizListView extends StatefulWidget{
  final List<DataEntry> data;
  final SwipeAction onSwipeLeft;
  final SwipeAction onSwipeRight;

  const VizListView({Key key, this.data, this.onSwipeLeft, this.onSwipeRight}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizListViewState();
}

class VizListViewState extends State<VizListView>{
  final double paddingValue = 5.0;

  @override
  Widget build(BuildContext context) {
    if(widget.data.length==0){
      return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Text('No data to show'),
      );
    }

    List<Widget> header = List<Widget>();
    widget.data.first.columns.forEach((String key, dynamic value){
      header.add(Expanded(child: Text(key.toString(),
        style: TextStyle(fontWeight: FontWeight.bold),)));
    });

    Row headerRow = Row(
      children: header,
    );

    List<VizListViewRow> rowsList = widget.data.map((DataEntry row) =>
        VizListViewRow(row, onSwipeLeft: widget.onSwipeLeft, onSwipeRight: widget.onSwipeRight)).toList();

    List<Widget> children = List<Widget>();
    children.add(headerRow);
    children.addAll(rowsList);

    return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children
          ),
        ),
      );
    }
}



class SwipeButton extends StatelessWidget{
  SwipeButton({@required this.onPressed, @required this.text});
  final GestureTapCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: FlatButton(
          color: const Color(0xFFEEEEEE),
          splashColor: const Color(0xFFFFFFFF),
          child: Text(
            text,
            maxLines: 1,
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
          onPressed: onPressed,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0))
      ),
    );
  }
}