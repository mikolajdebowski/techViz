import 'package:flutter/material.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/components/vizSummaryHeader.dart';
import 'package:techviz/model/dataEntry.dart';

class VizSummary extends StatefulWidget {
  final String title;
  final List<DataEntry> data;
  final List<String> groupByKeys;
  final SwipeAction onSwipeLeft;
  final SwipeAction onSwipeRight;
  VizSummary(this.title, this.data, this.groupByKeys, {Key key, this.onSwipeLeft, this.onSwipeRight}) : super(key: key);

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
      String keys = widget.groupByKeys[0];

      Map<String, dynamic> grouped = groupBy<DataEntry, String>(keySelector: (DataEntry entry) => entry.columns[keys], list: widget.data);
      Map<String, int> count = grouped.map<String, int>((String key, dynamic value) => MapEntry(key, (value as List).length));

      VizSummaryHeader header = VizSummaryHeader(headerTitle: widget.title, entries: count, actions: this, selectedEntryKey: _selectedEntryKey);

      if (!_expanded) {
        container = Container(
          key: Key('container'),
          decoration: boxDecoration,
          child: header,
        );
      } else {

        List<DataEntry> filtered = whereBy<DataEntry>(keySelector: (DataEntry entry) => entry.columns[keys]==_selectedEntryKey, list: widget.data);

        container = Container(
          key: Key('container'),
          decoration: boxDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              header,
              VizListView(data: filtered, onSwipeRight: widget.onSwipeRight, onSwipeLeft: widget.onSwipeLeft )
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