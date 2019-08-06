class DataEntryColumn{
	final DataAlignment alignment;
	final String columnName;
	final bool visible;
	final int flex;

	DataEntryColumn(this.columnName, {this.alignment = DataAlignment.left, this.visible = true, this.flex = 1});
}

enum DataAlignment{
	left,right,center
}