import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:techviz/model/dataEntry.dart';
import 'package:shimmer/shimmer.dart';

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
  final double paddingValue = 10.0;
  final double buttonPaddingValue = 0.0;


  BoxDecoration decoration = BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.black, width: 1.0))
  );

  final SizedBox left_swipe_ico = SizedBox(
    width: 64.0,
    child: Shimmer.fromColors(
      baseColor: Colors.white70,
      highlightColor: Colors.grey,
      child: Text(
        'slide>',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 15.0,
          fontWeight:
          FontWeight.bold,
          ),
        ),
      ),
    );


  final SizedBox right_swipe_ico = SizedBox(
    width: 64.0,
    child: Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.white10,
      child: Text(
        '<slide',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 15.0,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    ),
  );

  List<Widget> header;

  @override
  Widget build(BuildContext context) {
    if(widget.data.length==0){
      return Text('No data to show');
    }

    header = List<Widget>();
    widget.data[0].columns.forEach((String key, dynamic value){

      header.add(Expanded(child: Text(key.toString(),
        style: TextStyle(fontWeight: FontWeight.bold),)));
    });


    if(widget.onSwipeLeft!=null){
      header.add(Opacity(
        opacity: 1.0,
        child: left_swipe_ico,
      ));
    }
    else{
      header.add(Opacity(
        opacity: 0.0,
        child: left_swipe_ico,
      ));
    }

    if(widget.onSwipeRight!=null){
      header.insert(0, Opacity(
        opacity: 1.0,
        child: right_swipe_ico,
      ));
    }
    else{
      header.insert(0, Opacity(
        opacity: 0.0,
        child: right_swipe_ico,
      ));
    }


    Row headerRow = Row(
      children: header,
    );

    List<Slidable> rowsList = widget.data.map((DataEntry row){

      final GlobalKey<SlidableState> _slidableKey = GlobalKey<SlidableState>();

      List<Widget> columns = List<Widget>();
      row.columns.forEach((String key, dynamic value){
        columns.add(Expanded(child: Text(value.toString())));
      });

      Row dataRow = Row(
        children: columns,
      );

      GestureDetector gestureDetector = GestureDetector(
        child: dataRow,
        onTap: (){
          SlidableState slidableState = _slidableKey.currentState;
          slidableState.close();
        },
      );

      List<Widget> leftActions = List<Widget>();
      if(widget.onSwipeLeft!=null){

//        columns.add(left_swipe_ico);
        columns.add(Opacity(
          opacity: 0.0,
          child: right_swipe_ico,
        ));

        leftActions.add(Padding(
          padding: EdgeInsets.all(buttonPaddingValue),
          child: RaisedButton(onPressed: (){
                widget.onSwipeLeft.callback(row);
              }, child: Text(widget.onSwipeLeft.title)),
        ),);
      }
      else {
        columns.add(Opacity(
          opacity: 0.0,
          child: right_swipe_ico,
        ));
      }

      List<Widget> rightActions = List<Widget>();
      if(widget.onSwipeRight!=null){

//        columns.insert(0, right_swipe_ico);
        columns..insert(0, (Opacity(
          opacity: 0.0,
          child: right_swipe_ico,
        )));

        rightActions.add(Padding(
          padding: EdgeInsets.all(buttonPaddingValue),
          child: RaisedButton(onPressed: (){
                widget.onSwipeRight.callback(row);
              }, child: Text(widget.onSwipeRight.title)),
        ),
        );
      }
      else {
        columns.insert(0, (Opacity(
          opacity: 0.0,
          child: left_swipe_ico,
        )));
      }

      Slidable slidable = Slidable(
        key: _slidableKey,
        controller: slidableController,
        delegate: SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child:  Container(
          decoration: decoration,
          height: widget.rowHeight,
          child:  gestureDetector,
        ),
        actions: rightActions,
        secondaryActions: leftActions
      );

      return slidable;
    }).toList();

    List<Widget> children = List<Widget>();
    children.add(headerRow);
    children.addAll(rowsList);




    return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            children: children
          ),
        ),
      );
    }
}