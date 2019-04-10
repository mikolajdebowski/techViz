import 'package:flutter/material.dart';
import 'package:techviz/components/vizSummaryHeader.dart';
import 'package:techviz/model/summaryEntry.dart';

class VizSummary extends StatefulWidget {
  final String title;
  final List<SummaryEntry> data;
  final List<String> groupByKeys;

  VizSummary(this.title, this.data, this.groupByKeys, {Key key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    BoxDecoration boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Color(0xFFFFFFFF)),
        gradient: LinearGradient(
            colors: [Color(0xFF81919D), Color(0xFFAAB7BD)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated));

    if (widget.data == null) {
      Container container = Container(
        decoration: boxDecoration,
        child: Center(
            child: Padding(
          child: CircularProgressIndicator(),
          padding: EdgeInsets.all(10.0),
        )),
      );
      return container;
    }

    String keys = widget.groupByKeys[0];

    Map<String, dynamic> grouped = groupBy<SummaryEntry, String>(keySelector: (SummaryEntry entry) => entry.items[keys], list: widget.data);
    Map<String, int> count = grouped.map<String, int>((String key, dynamic value) => MapEntry(key, (value as List).length));

    VizSummaryHeader header = VizSummaryHeader(headerTitle: widget.title, entries: count, actions: this, selectedEntryKey: _selectedEntryKey);
    Container container;
    if (!_expanded) {
      container = Container(
        decoration: boxDecoration,
        child: header,
      );
    } else {
      container = Container(
        decoration: boxDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            header,
            Container(
              height: 100,
              child: Text('list $_selectedEntryKey goes here '),
            )
          ],
        ),
      );
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
