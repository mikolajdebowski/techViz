import 'package:flutter/material.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/components/vizListViewRow.dart';
import 'package:techviz/components/vizSummaryHeader.dart';

import 'dataEntry/dataEntry.dart';
import 'dataEntry/dataEntryColumn.dart';
import 'dataEntry/dataEntryGroup.dart';

class VizSummary extends StatefulWidget {
  final String title;
  final List<DataEntryGroup> data;
  final SwipeAction onSwipeLeft;
  final SwipeAction onSwipeRight;
  final Function onMetricTap;
  final bool isProcessing;
  final OnScroll onScroll;

  const VizSummary(this.title, this.data,
      {Key key,
      this.onSwipeLeft,
      this.onSwipeRight,
      this.onMetricTap,
      this.isProcessing = false,
      this.onScroll})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => VizSummaryState();
}

class VizSummaryState extends State<VizSummary>
    implements VizSummaryHeaderActions {
  bool _expanded = false;
  String _selectedEntryKey;

  Map<K, List<T>> groupBy<T, K>({K Function(T) keySelector, List<T> list}) {
    Map<K, List<T>> destination = {};

    for (T element in list) {
      final key = keySelector(element);
      final value = destination[key] ?? [];
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
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.white),
        color: Colors.white);

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
    } else {
      VizSummaryHeader header = VizSummaryHeader(
          headerTitle: widget.title,
          entries: widget.data,
          actions: this,
          selectedEntryKey: _selectedEntryKey,
          isProcessing: widget.isProcessing);

      if (!_expanded) {
        container = Container(
          key: Key('container'),
          decoration: boxDecoration,
          child: header,
        );
      } else {
        Widget child;
        Iterable<DataEntryGroup> _filterWhere = widget.data.where(
            (DataEntryGroup group) => group.headerTitle == _selectedEntryKey);
        List<DataEntry> _filteredData = _filterWhere.first.entries;
        List<DataEntryColumn> _columnsDefinition =
            _filterWhere.first.columnsDefinition;
        double _maxHeight = listViewMaxHeight(_filteredData.length);

        if (widget.isProcessing) {
          child = Container(
              height: _maxHeight,
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)))));
        } else {
          child = VizListView(_filteredData, _columnsDefinition,
              onSwipeRight: widget.onSwipeRight,
              onSwipeLeft: widget.onSwipeLeft,
              onScroll: widget.onScroll,
              maxHeight: _maxHeight);
        }

        container = Container(
          key: Key('container'),
          decoration: boxDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              header,
              child,
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

  double listViewMaxHeight(int rowCount) {
    return rowCount == 0
        ? VizListViewRow.rowHeight
        : (rowCount < 4
            ? rowCount * VizListViewRow.rowHeight
            : VizListViewRow.rowHeight * 4);
  }

  @override
  void onItemTap(String selectedEntryKey) {
    if (widget.onMetricTap != null) {
      widget.onMetricTap();
    }

    setState(() {
      if (_selectedEntryKey == selectedEntryKey) {
        _expanded = false;
        _selectedEntryKey = null;
      } else {
        _selectedEntryKey = selectedEntryKey;
        _expanded = true;
      }
    });
  }
}
