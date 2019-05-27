import 'dart:ui';

typedef ActionConditional = bool Function();
typedef HighlightedDecoration = Color Function();

class DataEntryGroup{
  final String headerTitle;
  final List<DataEntry> entries;
  final HighlightedDecoration highlightedDecoration;

  DataEntryGroup(this.headerTitle, this.entries, {this.highlightedDecoration});
}

class DataEntry{
  final String id;
  final List<DataEntryCell> columns;
  final ActionConditional onSwipeLeftActionConditional;
  final ActionConditional onSwipeRightActionConditional;

  DataEntry(this.id, this.columns, {this.onSwipeLeftActionConditional, this.onSwipeRightActionConditional});
}

class DataEntryCell{
  final DataAlignment alignment;
  final String column;
  final dynamic value;

  @override
  String toString(){
    return value.toString();
  }

  DataEntryCell(this.column, this.value, {this.alignment = DataAlignment.left});
}

enum DataAlignment{
  left,right,center
}