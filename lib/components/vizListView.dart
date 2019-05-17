import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  final double rowHeight = 35.0;


  const VizListView({Key key, this.data, this.onSwipeLeft, this.onSwipeRight}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizListViewState();
}

class VizListViewState extends State<VizListView>{
  final SlidableController slidableController = new SlidableController();
  final double paddingValue = 5.0;

  BoxDecoration decoration = BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.black, width: 1.0))
  );

  List<Widget> header;

  @override
  Widget build(BuildContext context) {
    if(widget.data.length==0){
      return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Text('No data to show'),
      );
    }

    header = List<Widget>();
    widget.data[0].columns.forEach((String key, dynamic value){

      header.add(Expanded(child: Text(key.toString(),
        style: TextStyle(fontWeight: FontWeight.bold),)));
    });


    Row headerRow = Row(
      children: header,
    );

    List<Slidable> rowsList = widget.data.map((DataEntry row){

      final GlobalKey<SlidableState> _slidableKey = GlobalKey<SlidableState>();

      List<Widget> columns = List<Widget>();
      row.columns.forEach((String key, dynamic value){
        String text = value.toString();
        TextStyle style = TextStyle(fontSize: text.length>= 20? 10: 12);

        columns.add(Expanded(child: Text(text, style: style, overflow: TextOverflow.ellipsis, softWrap: true, maxLines: 2,)));
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
        leftActions.add(SwipeButton(text: widget.onSwipeLeft.title, onPressed: (){
          widget.onSwipeLeft.callback(row);
        }));
      }

      List<Widget> rightActions = List<Widget>();
      if(widget.onSwipeRight!=null){
        rightActions.add(SwipeButton(text: widget.onSwipeRight.title, onPressed: (){
          widget.onSwipeRight.callback(row);
        }));
      }

      Slidable slidable = Slidable(
        key: _slidableKey,
        controller: slidableController,
        actionPane: SlidableStrechActionPane(),
        actionExtentRatio: 0.25,
        child:  Container(
          decoration: decoration,
          height: widget.rowHeight,
          child:  gestureDetector,
        ),
        actions: rightActions,
        secondaryActions: leftActions,
        dismissal: SlidableDismissal(
          dismissThresholds: <SlideActionType, double>{
            SlideActionType.secondary: 1.0,
            SlideActionType.primary:1.0
          },
          child: SlidableDrawerDismissal(),
          onDismissed: (actionType) {

          },
        ),

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
          color: const Color(0xFFDDDDDD),
          splashColor: const Color(0xFFFFFFFF),
          child: Text(
            text,
            maxLines: 1,
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
          onPressed: onPressed,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))
      ),
    );
  }
}