import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:techviz/model/dataEntry.dart';

typedef SwipeActionCallback = void Function(dynamic tag);

class SwipeAction{
  final String title;
  final SwipeActionCallback callback;

  SwipeAction(this.title, this.callback);
}

class VizListView extends StatefulWidget{
  final List<DataEntry> data;
  final SwipeAction callbackLeft;
  final SwipeAction callbackRight;
  final double rowHeight = 40.0;

  const VizListView({Key key, this.data, this.callbackLeft, this.callbackRight}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizListViewState();
}

class VizListViewState extends State<VizListView>{
  final SlidableController slidableController = new SlidableController();
  final double paddingValue = 10.0;
  List<Widget> header;



  @override
  Widget build(BuildContext context) {


    if(widget.data.length==0){
      return Text('No data to show');
    }

    header = List<Widget>();
    widget.data[0].items.forEach((String key, dynamic value){

      header.add(Expanded(child: Text(key.toString())));
    });

    Row headerRow = Row(
      children: header,
    );

    Padding headerPadding = Padding(
      child: headerRow, padding: EdgeInsets.all(paddingValue),
    );

    List<Slidable> rowsList = widget.data.map((DataEntry row){

      List<Widget> columns = List<Widget>();
      row.items.forEach((String key, dynamic value){

        columns.add(Expanded(child: Text(value.toString())));
      });

      Row dataRow = Row(
        children: columns,
      );
      
      Padding padding = Padding(
        child: dataRow, padding: EdgeInsets.all(paddingValue),
      );

      List<GestureDetector> leftActions = List<GestureDetector>();
      if(widget.callbackLeft!=null){
        leftActions.add(GestureDetector(
          onTap: (){
            widget.callbackLeft.callback;
          },
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Text(widget.callbackLeft.title),
          ),
        ));
      }

      List<GestureDetector> rightActions = List<GestureDetector>();
      if(widget.callbackRight!=null){
        rightActions.add(GestureDetector(
          onTap: (){
            widget.callbackRight.callback;
          },
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Text(widget.callbackRight.title),
          ),
        ));
      }

      Slidable slidable = Slidable(
        controller: slidableController,
        delegate: SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child:  Container(
          height: widget.rowHeight,
          child:  padding,
        ),
        actions: rightActions,
        secondaryActions: leftActions
      );


      return slidable;
    }).toList();

    List<Widget> children = List<Widget>();
    children.add(headerPadding);
    children.addAll(rowsList);


    return SingleChildScrollView(
        child: Column(
          children: children
        ),
      );
    }
}