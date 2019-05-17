import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/model/dataEntry.dart';

class VizListViewRow extends StatefulWidget{
  final DataEntry dataEntry;
  final SwipeAction onSwipeLeft;
  final SwipeAction onSwipeRight;

  const VizListViewRow(this.dataEntry, {Key key, this.onSwipeLeft, this.onSwipeRight}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizListViewRowState();

}

class VizListViewRowState extends State<VizListViewRow>{
  final double rowHeight = 35.0;
  final GlobalKey<SlidableState> _slidableKey = GlobalKey<SlidableState>();
  bool isBeingPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgRowColor = isBeingPressed ? Colors.lightBlue : Colors.transparent;
    BoxDecoration decoration = BoxDecoration(
      color: bgRowColor, border: Border(bottom: BorderSide(color: Colors.black, width: 1.0))
    );

    List<Widget> columns = List<Widget>();
    widget.dataEntry.columns.forEach((String key, dynamic value){
      String text = value.toString();
      TextStyle style = TextStyle(fontSize: text.length>= 20? 10: 12);

      columns.add(Expanded(child: Text(text, style: style, overflow: TextOverflow.ellipsis, softWrap: true, maxLines: 2,)));
    });

    Row dataRow = Row(
      children: columns,
    );

    List<Widget> leftActions = List<Widget>();
    if(widget.onSwipeLeft!=null){
      leftActions.add(SwipeButton(text: widget.onSwipeLeft.title, onPressed: (){
        widget.onSwipeLeft.callback(widget.dataEntry);
      }));
    }

    List<Widget> rightActions = List<Widget>();
    if(widget.onSwipeRight!=null){
      rightActions.add(SwipeButton(text: widget.onSwipeRight.title, onPressed: (){
        widget.onSwipeRight.callback(widget.dataEntry);
      }));
    }

    Slidable slidable = Slidable(
      key: _slidableKey,
      controller: SlidableController(),
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        decoration: decoration,
        height: rowHeight,
        child:  dataRow,
      ),
      actions: rightActions,
      secondaryActions: leftActions,
      dismissal: SlidableDismissal(
        dismissThresholds: <SlideActionType, double>{
          SlideActionType.secondary: 1.0,
          SlideActionType.primary:1.0
        },
        child: SlidableDrawerDismissal(),
        onDismissed: (actionType) {},
      ),
    );

    GestureDetector gestureDetector = GestureDetector(
        child: slidable,
        onTap: (){
          SlidableState slidableState = _slidableKey.currentState;
          slidableState.close();
          setState(() {
            this.isBeingPressed = false;
          });
        }
    );

    Listener listener = Listener(
        child: gestureDetector,
        onPointerDown: (PointerDownEvent event){
          setState(() {
            this.isBeingPressed = true;
          });
        },
        onPointerUp: (PointerUpEvent event){
          setState(() {
            this.isBeingPressed = false;
          });
        },
    );
    return listener;
  }



}