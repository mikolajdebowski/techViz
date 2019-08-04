import 'dart:ui';
import 'package:techviz/components/dataEntry/dataEntry.dart';

import 'dataEntryColumn.dart';

typedef HighlightedDecoration = Color Function();

class DataEntryGroup{
  final String headerTitle;
  final List<DataEntry> entries;
  final List<DataEntryColumn> columnsDefinition;
  final HighlightedDecoration highlightedDecoration;

  DataEntryGroup(this.headerTitle, this.entries, this.columnsDefinition, {this.highlightedDecoration});
}