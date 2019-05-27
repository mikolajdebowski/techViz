import 'package:techviz/components/dataEntry/dataEntryCell.dart';

typedef ActionConditional = bool Function();

class DataEntry{
  final String id;
  final List<DataEntryCell> columns;
  final ActionConditional onSwipeLeftActionConditional;
  final ActionConditional onSwipeRightActionConditional;

  DataEntry(this.id, this.columns, {this.onSwipeLeftActionConditional, this.onSwipeRightActionConditional});
}