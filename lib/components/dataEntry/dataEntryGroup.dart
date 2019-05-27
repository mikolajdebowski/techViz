import 'dart:ui';
import 'package:techviz/components/dataEntry/dataEntry.dart';

typedef HighlightedDecoration = Color Function();

class DataEntryGroup{
  final String headerTitle;
  final List<DataEntry> entries;
  final HighlightedDecoration highlightedDecoration;

  DataEntryGroup(this.headerTitle, this.entries, {this.highlightedDecoration});
}