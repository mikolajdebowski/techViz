import 'package:flutter/material.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/components/vizListViewRow.dart';
import 'package:techviz/components/vizSummaryHeader.dart';
import 'package:techviz/model/dataEntry.dart';

class VizSummary extends StatefulWidget {
  final String title;
  final List<DataEntryGroup> data;
  final SwipeAction onSwipeLeft;
  final SwipeAction onSwipeRight;
  final Function onMetricTap;
  final bool isProcessing;
  final OnScroll onScroll;

  VizSummary(this.title, this.data, {Key key, this.onSwipeLeft, this.onSwipeRight, this.onMetricTap, this.isProcessing = false, this.onScroll}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizSummaryState();
}

class VizSummaryState extends State<VizSummary> implements VizSummaryHeaderActions {
  bool _expanded = false;
  String _selectedEntryKey;

  Map<K, List<T>> groupBy<T, K>({K Function(T) keySelector, List<T> list}) {
    Map<K, List<T>> destination = Map();

    for (T element in list) {
      final key = keySelector(element);
      final value = destination[key] ?? List();
      value.add(element);
      destination[key] = value;
    }

    return destination;
  }

  List<T> whereBy<T>({bool Function(T) keySelector, List<T> list}) {
    return list.where((T element) => keySelector(element)).toList();
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Color(0xFFFFFFFF)),
        gradient: LinearGradient(
            colors: [Color(0xFF81919D), Color(0xFFAAB7BD)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated));


    Container container;
    if (widget.data == null) {
      container = Container(
        key: Key('container'),
        decoration: boxDecoration,
        child: Center(
            child: Padding(
          child: CircularProgressIndicator(),
          padding: EdgeInsets.all(10.0),
        )),
      );
    }
    else{
      Map<String,int> count = Map<String,int>();
      widget.data.forEach((DataEntryGroup group){
        count[group.headerTitle] = group.entries.length;
      });

      VizSummaryHeader header = VizSummaryHeader(headerTitle: widget.title, entries: count, actions: this, selectedEntryKey: _selectedEntryKey, isProcessing: widget.isProcessing);

      if (!_expanded) {
        container = Container(
          key: Key('container'),
          decoration: boxDecoration,
          child: header,
        );
      } else {

        Widget child;

        if(widget.isProcessing){
          child = Center(
            child: Padding(padding: EdgeInsets.all(5.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          );
        }
        else {
          Iterable<DataEntryGroup> where = widget.data.where((DataEntryGroup group)=> group.headerTitle == _selectedEntryKey);
          List<DataEntry> filtered = where.first.entries;
          child = VizListView(data: filtered, onSwipeRight: widget.onSwipeRight, onSwipeLeft: widget.onSwipeLeft, onScroll: widget.onScroll);
        }

        container = Container(
          key: Key('container'),
          decoration: boxDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              header,child

            ],
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(left: 5, top: 5, right: 5),
      child: container,
    );
  }

  @override
  void onItemTap(String selectedEntryKey) {

    if(widget.onMetricTap!=null){
      widget.onMetricTap();
    }

    setState(() {
      if(_selectedEntryKey == selectedEntryKey){
        _expanded = false;
        _selectedEntryKey = null;
      }
      else{
        _selectedEntryKey = selectedEntryKey;
        _expanded = true;
      }
    });
  }
}