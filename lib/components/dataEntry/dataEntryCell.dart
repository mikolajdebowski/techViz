class DataEntryCell{
  final DataAlignment alignment;
  final String column;
  final dynamic value;
  final bool visible;

  @override
  String toString(){
    return value.toString();
  }

  DataEntryCell(this.column, this.value, {this.alignment = DataAlignment.left, this.visible = true});
}

enum DataAlignment{
  left,right,center
}