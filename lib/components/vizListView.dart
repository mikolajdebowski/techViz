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
  final SwipeAction onSwipeLeft;
  final SwipeAction onSwipeRight;
  final double rowHeight = 40.0;

  const VizListView({Key key, this.data, this.onSwipeLeft, this.onSwipeRight}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizListViewState();
}

class VizListViewState extends State<VizListView>{
  final SlidableController slidableController = new SlidableController();
  final double paddingValue = 5.0;
  //

  @override
  Widget build(BuildContext context) {
    if(widget.data.length==0){
      return Text('No data to show');
    }

    List<Slidable> rowsList = widget.data.map((DataEntry row){

      final GlobalKey<SlidableState> _slidableKey = GlobalKey<SlidableState>();

      List<Widget> columns = List<Widget>();
      row.columns.forEach((String key, dynamic value){

        columns.add(Expanded(child: Text(value.toString())));
      });

      Row dataRow = Row(
        children: columns,
      );
      
      Padding padding = Padding(
        child: dataRow, padding: EdgeInsets.all(paddingValue),
      );

      GestureDetector gestureDetector = GestureDetector(
        child: padding,
        onTap: (){
          SlidableState slidableState = _slidableKey.currentState;
          slidableState.close();
        },
      );

      List<Widget> leftActions = List<Widget>();
      if(widget.onSwipeLeft!=null){
        leftActions.add(Padding(
            padding: EdgeInsets.all(paddingValue),
            child: RaisedButton(onPressed: (){
              widget.onSwipeLeft.callback(row);
            }, child: Text(widget.onSwipeLeft.title)),
          ),
        );
      }

      List<Widget> rightActions = List<Widget>();
      if(widget.onSwipeRight!=null){
        rightActions.add(Padding(
            padding: EdgeInsets.all(paddingValue),
            child: RaisedButton(onPressed: (){
              widget.onSwipeRight.callback(row);
            }, child: Text(widget.onSwipeRight.title)),
          ),
        );
      }

      Slidable slidable = Slidable(
        key: _slidableKey,
        controller: slidableController,
        delegate: SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child:  Container(
          height: widget.rowHeight,
          child:  gestureDetector,
        ),
        actions: rightActions,
        secondaryActions: leftActions
      );

      return slidable;
    }).toList();



    double listHeight = widget.rowHeight*widget.data.length;
    if(widget.data.length>8){
      return ListView(
          //put height = widget.rowHeight * 8;
          children: rowsList
      );
    }
    else{
      return ListView(
          //put minHeigh
          children: rowsList
      );
    }

  }
}