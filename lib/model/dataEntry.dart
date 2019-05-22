class DataEntryGroup{
  final String headerTitle;
  final List<DataEntry> entries;

  DataEntryGroup(this.headerTitle, this.entries);
}

class DataEntry{
  final String id;
  final List<DataEntryCell> columns;

  DataEntry(this.id, this.columns);
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