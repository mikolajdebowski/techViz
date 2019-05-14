class DataEntry{
  final String id;
  final Map<String,dynamic> columns;

  DataEntry(this.id, this.columns);
}

class DataEntryGroup{
  final String headerTitle;
  final List<DataEntry> entries;

  DataEntryGroup(this.headerTitle, this.entries);
}