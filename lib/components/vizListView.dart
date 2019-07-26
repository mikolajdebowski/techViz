import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dataEntry/dataEntry.dart';
import 'dataEntry/dataEntryCell.dart';
import 'vizListViewRow.dart';

typedef SwipeActionCallback = void Function(dynamic tag);
typedef OnScroll = void Function(ScrollingStatus scroll);
typedef Swipable = bool Function(dynamic parameter);

class VizListView extends StatefulWidget {
  final List<DataEntry> data;
  final SwipeAction onSwipeLeft;
  final SwipeAction onSwipeRight;
  final OnScroll onScroll;

  const VizListView({Key key, this.data, this.onSwipeLeft, this.onSwipeRight, this.onScroll}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizListViewState();
}

class VizListViewState extends State<VizListView> {
  final double paddingValue = 5.0;
  final int numOfRows = 4;

  ScrollController _scrollController;
  GlobalKey<SlidableState> _lastRowkey;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
        widget.onScroll(ScrollingStatus.ReachOnBottom);
      } else if (_scrollController.offset <= _scrollController.position.minScrollExtent) {
        widget.onScroll(ScrollingStatus.ReachOnTop);
      }
    });
    super.initState();
  }


  void onRowSwiping(bool isOpen, GlobalKey<SlidableState> key){
    if(_lastRowkey==null){
      setState(() {
        _lastRowkey = key;
      });
    }
    else if(_lastRowkey!=null && _lastRowkey.hashCode != key.hashCode){
      if(_lastRowkey.currentState != null){
        _lastRowkey.currentState.close();
      }

      setState(() {
        _lastRowkey = key;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: paddingValue, bottom: paddingValue),
        child: Text('No data to show'),
      );
    }

    List<Widget> header = <Widget>[];
    widget.data.first.columns.forEach((DataEntryCell dataCell) {
      if(!dataCell.visible)
        return;


      header.add(Expanded(
          child: Text(
        dataCell.column.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      )));
    });

    //HEADER
    Row headerRow = Row(
      children: header,
    );

    //LISTVIEW
    List<VizListViewRow> rowsList =
        widget.data.map((DataEntry row) => VizListViewRow(row, onSwipeLeft: widget.onSwipeLeft, onSwipeRight: widget.onSwipeRight, onSwiping: onRowSwiping)).toList();

    double maxHeight = widget.data.isEmpty ? VizListViewRow.rowHeight : (widget.data.length < numOfRows ? widget.data.length * VizListViewRow.rowHeight : VizListViewRow.rowHeight * numOfRows);

    Container listViewContainer = Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView(
        controller: _scrollController,
        children: rowsList,
      ),
    );

    return SingleChildScrollView(
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(
          decoration: BoxDecoration(color: Color(0xFFF1F1F1)),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: headerRow,
          )), listViewContainer]),
    );
  }
}

class SwipeButton extends StatelessWidget {
  const SwipeButton({@required this.onPressed, @required this.text, this.color});

  final Color color;
  final GestureTapCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
          color:  onPressed == null ? Color(0xFFC1C1C1): color,
          splashColor: onPressed == null ? Color(0xFFC1C1C1) : color,
          child: AutoSizeText(
            text,
            maxLines: 1,
            style: TextStyle(color: onPressed == null ? Colors.grey[200]: Colors.white , fontSize: 10),
          ),
          onPressed: (){
            if(onPressed!=null){
              onPressed();
            }
          },
          materialTapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
      );
  }
}

enum ScrollingStatus { ReachOnTop, ReachOnBottom, IsScrolling }