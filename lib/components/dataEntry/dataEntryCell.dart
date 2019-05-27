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