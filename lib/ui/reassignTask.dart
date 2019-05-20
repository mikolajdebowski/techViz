import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/presenter/reassignPresenter.dart';

class ReassignTask extends StatefulWidget {
  final String taskID;
  final String location;

  const ReassignTask(this.taskID, this.location, {Key key, }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReassignTaskState();
}

class ReassignTaskState extends State<ReassignTask> implements IReassignPresenter {
  String _selectedValue;
  List<User> _userList;
  ReassignPresenter _presenter;
  bool _processing = false;

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
    // TODO: implement onLoadError
  }

  @override
  void onUserLoaded(List<User> list) {
    setState(() {
      _userList = list;
    });
  }

  List<DataRow> getRowsOfUsers() {
    return List<DataRow>.generate(_userList.length, (int index) => DataRow(selected: _selectedValue == _userList[index].userID,
        cells: [
           DataCell(Text(_userList[index].userID), onTap: (){
             onCellTap(_userList[index].userID);
           }),
           DataCell(Text('1,2,3'), onTap: (){
             onCellTap(_userList[index].userID);
           }),
           DataCell(Text('1'), onTap: (){
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
                _userList.sort((a,b)=> ascending ? a.userID.compareTo(b.userID) : b.userID.compareTo(a.userID));
                _sortColumnIndex = index;
                _sortAscending = ascending;
              });
            }
        ),
        DataColumn(
            label: Text("Sections", style: TextStyle(fontWeight: FontWeight.bold)),
            onSort: (int index, bool ascending){
              setState(() {
                _userList.sort((a,b)=> ascending ? a.userID.compareTo(b.userID) : b.userID.compareTo(a.userID));
                _sortColumnIndex = index;
                _sortAscending = ascending;
              });
            }
        ),
        DataColumn(
            label: Text("Task count", style: TextStyle(fontWeight: FontWeight.bold)),
            onSort: (int index, bool ascending){
              setState(() {
                _userList.sort((a,b)=> ascending ? a.userID.compareTo(b.userID) : b.userID.compareTo(a.userID));
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
    setState(() {
      _processing = true;
    });

    _presenter.reassign(widget.taskID, _selectedValue).then((dynamic result) {
      setState(() {
        _processing = false;
      });
      Navigator.of(context).pop(true);
    }).catchError((dynamic error){
      //TODO: HANDLE proper error message
      setState(() {
        _processing = false;
      });
    });
  }
}
