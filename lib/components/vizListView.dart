import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VizListView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => VizListViewState();
}

class VizListViewState extends State<VizListView>{
  int _sortColumnIndex = 1;
  bool _sortAscending = true;
  ResultsDataSource _resultsDataSource = ResultsDataSource([]);

  var data = <RowObject>[
    RowObject(location: "01-01-01", type:"Printer", status: "Assigned", user: "Joe", time: "1:03"),
    RowObject(location: "01-01-02", type:"Change", status: "Carded", user: "Amy", time: "2:32"),
    RowObject(location: "02-01-04", type:"Tilt", status: "Acknowledged", user: "Bob", time: "0:45"),
    RowObject(location: "03-08-12", type:"Jackpot", status: "Jackpot", user: "Susan", time: "12:18"),
    RowObject(location: "G-01-05", type:"Verify", status: "Carded", user: "James", time: "3:15"),
    RowObject(location: "D-04-08", type:"Change", status: "Acknowledged", user: "Michelle", time: "0:28"),
    RowObject(location: "05-01-01", type:"Bill", status: "Carded", user: "Joe", time: "4:55"),
    RowObject(location: "01-01-01", type:"Printer", status: "Assigned", user: "Joe", time: "1:03"),
    RowObject(location: "01-01-02", type:"Change", status: "Carded", user: "Amy", time: "2:32"),
    RowObject(location: "02-01-04", type:"Tilt", status: "Acknowledged", user: "Bob", time: "0:45"),
    RowObject(location: "03-08-12", type:"Jackpot", status: "Jackpot", user: "Susan", time: "12:18"),
    RowObject(location: "G-01-05", type:"Verify", status: "Carded", user: "James", time: "3:15"),
    RowObject(location: "D-04-08", type:"Change", status: "Acknowledged", user: "Michelle", time: "0:28"),
    RowObject(location: "05-01-01", type:"Bill", status: "Carded", user: "Joe", time: "4:55"),
    RowObject(location: "01-01-01", type:"Printer", status: "Assigned", user: "Joe", time: "1:03"),
    RowObject(location: "01-01-02", type:"Change", status: "Carded", user: "Amy", time: "2:32"),
    RowObject(location: "02-01-04", type:"Tilt", status: "Acknowledged", user: "Bob", time: "0:45"),
    RowObject(location: "03-08-12", type:"Jackpot", status: "Jackpot", user: "Susan", time: "12:18"),
    RowObject(location: "G-01-05", type:"Verify", status: "Carded", user: "James", time: "3:15"),
    RowObject(location: "D-04-08", type:"Change", status: "Acknowledged", user: "Michelle", time: "0:28"),
    RowObject(location: "05-01-01", type:"Bill", status: "Carded", user: "Joe", time: "4:55"),
    RowObject(location: "01-01-01", type:"Printer", status: "Assigned", user: "Joe", time: "1:03"),
    RowObject(location: "01-01-02", type:"Change", status: "Carded", user: "Amy", time: "2:32"),
    RowObject(location: "02-01-04", type:"Tilt", status: "Acknowledged", user: "Bob", time: "0:45"),
    RowObject(location: "03-08-12", type:"Jackpot", status: "Jackpot", user: "Susan", time: "12:18"),
    RowObject(location: "G-01-05", type:"Verify", status: "Carded", user: "James", time: "3:15"),
    RowObject(location: "D-04-08", type:"Change", status: "Acknowledged", user: "Michelle", time: "0:28"),
    RowObject(location: "05-01-01", type:"Bill", status: "Carded", user: "Joe", time: "4:55"),
  ];

  void _sort<T>(
      Comparable<T> getField(RowObject d), int columnIndex, bool ascending) {
    _resultsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {

    DataColumn col1 = DataColumn(
        label: Text("Location",
          style: TextStyle(fontWeight: FontWeight.bold),),
        numeric: false,
        tooltip: "Location Column"
    );

    DataColumn col2 = DataColumn(
        label: Text("Type",
          style: TextStyle(fontWeight: FontWeight.bold),),
        numeric: false,
        tooltip: "Type Column",
        onSort: (i, b){
          print("$i $b");

          setState(() {
            data.sort((a, b) => a.type.compareTo(b.type));
          });
        }
    );

    DataColumn col3 = DataColumn(
        label: Text("Status",
          style: TextStyle(fontWeight: FontWeight.bold),),
        numeric: false,
        tooltip: "Status Column"
    );

    DataColumn col4 = DataColumn(
        label: Text("User",
          style: TextStyle(fontWeight: FontWeight.bold),),
        numeric: false,
        tooltip: "User Column"
    );

    DataColumn col5 = DataColumn(
        label: Text("Time",
          style: TextStyle(fontWeight: FontWeight.bold),),
        numeric: false,
        tooltip: "Time Column"
    );

    DataTable table = DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: <DataColumn>[
          col1, col2,  col3, col4,  col5
        ],

        rows: data.map((RowObject row)=>DataRow(
            cells: [
              DataCell(Text(row.location)),
              DataCell(Text(row.type)),
              DataCell(Text(row.status)),
              DataCell(Text(row.user)),
              DataCell(Text(row.time), showEditIcon: false, placeholder: false),
            ]
        )).toList()

    );

    print(table.rows.length);
    return SizedBox(child: ListView(children: <Widget>[table]));
  }
}

class RowObject{
  final String location;
  final String type;
  final String status;
  final String user;
  final String time;

  RowObject({this.location, this.type, this.status, this.user, this.time});

  bool selected = false;
}

class ResultsDataSource extends DataTableSource {
  final List<RowObject> _results;

  ResultsDataSource(this._results);

  void _sort<T>(Comparable<T> getField(RowObject d), bool ascending) {
    _results.sort((RowObject a, RowObject b) {
      if (!ascending) {
        final RowObject c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _results.length) return null;
    final RowObject result = _results[index];
    return DataRow.byIndex(
        index: index,
        selected: result.selected,
        onSelectChanged: (bool value) {
          if (result.selected != value) {
            _selectedCount += value ? 1 : -1;
            assert(_selectedCount >= 0);
            result.selected = value;
            notifyListeners();
          }
        },
        cells: <DataCell>[
          DataCell(Text('${result.location}')),
          DataCell(Text('${result.type}')),
          DataCell(Text('${result.status}')),
          DataCell(Text('${result.user}')),
          DataCell(Text('${result.type}')),
        ]);
  }

  @override
  int get rowCount => _results.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool checked) {
    for (RowObject result in _results)
      result.selected = checked;
    _selectedCount = checked ? _results.length : 0;
    notifyListeners();
  }
}