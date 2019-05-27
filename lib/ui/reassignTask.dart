import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/presenter/reassignPresenter.dart';
import 'package:techviz/viewmodel/reassignUsers.dart';

class ReassignTask extends StatefulWidget {
  final String taskID;
  final String location;

  const ReassignTask(this.taskID, this.location, {Key key, }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReassignTaskState();
}

class ReassignTaskState extends State<ReassignTask> implements IReassignPresenter {
  String _selectedValue;
  List<ReassignUser> _userList;
  ReassignPresenter _presenter;

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();

    _presenter = ReassignPresenter(this);
    _presenter.loadUsers();
  }

  @override
  void onLoadError(dynamic error) {
    // TODO(rmathias): implement onLoadError
  }

  @override
  void onUserLoaded(List<ReassignUser> list) {
    setState(() {
      _userList = list;
      _userList.sort((a, b)=> a.userID.compareTo(b.userID));
    });
  }

  List<DataRow> getRowsOfUsers() {
    return List<DataRow>.generate(_userList.length, (int index) => DataRow(selected: _selectedValue == _userList[index].userID,
        cells: [
           DataCell(Text(_userList[index].userID), onTap: (){
             onCellTap(_userList[index].userID);
           }),
           DataCell(Text(_userList[index].sectionsCount.toString()), onTap: (){
             onCellTap(_userList[index].userID);
           }),
           DataCell(Text(_userList[index].taskCount.toString()), onTap: (){
             onCellTap(_userList[index].userID);
           }),
        ]));
  }

  void onCellTap(String userID){
    setState(() {
      setState(() {
        _selectedValue = userID;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget innerWidget;
    if(_userList==null){
      innerWidget = Center(child: Padding(
        padding: EdgeInsets.all(10),
        child: CircularProgressIndicator(),
      ));
    }
    else{
      innerWidget = DataTable(sortAscending: _sortAscending, sortColumnIndex: _sortColumnIndex,columns: <DataColumn>[
        DataColumn(
            label: Text("User", style: TextStyle(fontWeight: FontWeight.bold)),
            onSort: (int index, bool ascending){
              setState(() {
                _userList.sort((a, b)=> ascending ? a.userID.compareTo(b.userID) : b.userID.compareTo(a.userID));
                _sortColumnIndex = index;
                _sortAscending = ascending;
              });
            }
        ),
        DataColumn(
            numeric: true,
            label: Text("Sections Count", style: TextStyle(fontWeight: FontWeight.bold)),
            onSort: (int index, bool ascending){
              setState(() {
                _userList.sort((a, b)=> ascending ? a.sectionsCount.compareTo(b.sectionsCount) : b.sectionsCount.compareTo(a.sectionsCount));
                _sortColumnIndex = index;
                _sortAscending = ascending;
              });
            }
        ),
        DataColumn(
            numeric: true,
            label: Text("Tasks Count", style: TextStyle(fontWeight: FontWeight.bold)),
            onSort: (int index, bool ascending){
              setState(() {
                _userList.sort((a, b)=> ascending ? a.taskCount.compareTo(b.taskCount) : b.taskCount.compareTo(a.taskCount));
                _sortColumnIndex = index;
                _sortAscending = ascending;
              });
            }
        )
      ], rows: getRowsOfUsers());
    }

    SingleChildScrollView scrollView = SingleChildScrollView(
      child: innerWidget,
    );

    BoxDecoration defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));
    Container container = Container(
        decoration: defaultBgDeco,
        constraints: BoxConstraints.expand(),
        child: scrollView,
    );

    VizButton okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => reassign(), enabled: _selectedValue != null);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'Re-assign task ${widget.location}', titleColor: Colors.blue, tailWidget:okBtn),
      body:  SafeArea(child: container),
    );
  }

  void reassign() {
    if (_selectedValue == null) {
      return;
    }

    _presenter.reassign(widget.taskID, _selectedValue).then((dynamic result) {
      Navigator.of(context).pop(true);
    }).catchError((dynamic error){
      // TODO(rmathias): HANDLE proper error message
    });
  }
}
