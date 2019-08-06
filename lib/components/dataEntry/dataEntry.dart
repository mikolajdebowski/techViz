import 'package:techviz/components/dataEntry/dataEntryCell.dart';

typedef ActionConditional = bool Function();

class DataEntry{
  final String id;
  final List<DataEntryCell> cell;
  final ActionConditional onSwipeLeftActionConditional;
  final ActionConditional onSwipeRightActionConditional;

  DataEntry(this.id, this.cell, {this.onSwipeLeftActionConditional, this.onSwipeRightActionConditional});
}