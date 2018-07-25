import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techviz/components/vizTaskActionButton.dart';
import 'package:techviz/components/vizTimer.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/presenter/taskListPresenter.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskStatusRepository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class AttendantHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AttendantHomeState();
}

class AttendantHomeState extends State<AttendantHome> implements TaskListPresenterContract<Task>{
  TaskListPresenter _presenter;
  Task _selectedTask = null;
  List<Task> _taskList = [];
  List<TaskStatus> _taskStatusList = [];
  List<TaskType> _taskTypeList = [];

  var _taskListStatus = "assets/images/ic_processing.png";

  @override
  initState(){
    _taskList = [];

    _presenter = TaskListPresenter(this);
    _presenter.loadTaskList();

    _taskListStatus = "assets/images/ic_processing.png";

    TaskStatusRepository().getAll().then((List<TaskStatus> list) {
      _taskStatusList = list;

      TaskTypeRepository().getAll().then((List<TaskType> list) {
        _taskTypeList = list;
      });
    });

    super.initState();
  }


  @override
  void onTaskListLoaded(List<Task> result) {
    setState(() {
      _taskList = result;
      _taskListStatus = null;
    });
  }

  @override
  void onLoadError(Error error) {
    // TODO: implement onLoadError
  }


  void _onTaskItemTapped(Task task) {
    setState(() {
      _selectedTask = task;
    });
  }

  @override
  Widget build(BuildContext context)  {

    final defaultHeaderDecoration = BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
        gradient: LinearGradient(
            colors: [ Color(0xFF4D4D4D),  Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.repeated));

    //LEFT PANEL WIDGETS
    //task list header and task list

    var listTasks = <Widget>[];

    for (var i = 1; i <= _taskList.length; i++) {
      Task task = _taskList[i - 1];
      var taskItem = GestureDetector(
          onTap: (){
            _onTaskItemTapped(task);
          },
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: _selectedTask == task ? [Color(0xFF65b1d9),  Color(0xFF0268a2)]: [Color(0xFF45505D),  Color(0xFF282B34)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          tileMode: TileMode.repeated)),
                  child: Center(child: Text(i.toString(), style: TextStyle(color: Colors.white))),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFFB2C7CF),Color(0xFFE4EDEF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          tileMode: TileMode.repeated)),
                  child: Center(
                      child: Text(
                        task.location,
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
                      )),
                ),
              ),
            ],
          ));

      listTasks.add(taskItem);
    }


    var taskTextStr = listTasks.length == 0? 'No tasks' : (listTasks.length==1 ? '1 Task' : '${listTasks.length} Tasks');

    Widget listContainer = ImageIcon( AssetImage("assets/images/ic_processing.png"), size: 30.0);



    if(listTasks.length > 0)
      listContainer = ListView(
      children: listTasks,
    );

    var leftPanel = Flexible(
      flex: 1,
      child: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints.expand(height: 70.0),
            decoration: defaultHeaderDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(taskTextStr, style: TextStyle(color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: _taskListStatus != null? ImageIcon( AssetImage(_taskListStatus), size: 15.0, color: Colors.blueGrey) : null,
                      )

                    ],
                  ),
                ),
                Text('0 Pending', style: TextStyle(color: Colors.orange)),
                Text('Priority', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),

              ],
            ),
          ),
          Expanded(
            child: listContainer,
          )
        ],
      ),
    );


    var taskTypeDescr = _selectedTask!=null? _taskTypeList.where((t)=> t.id ==_selectedTask.taskTypeID).first.description: '';
    var taskStatusDescr = _selectedTask!=null? _taskStatusList.where((t)=> t.id ==_selectedTask.taskStatusID).first.description: '';



    //CENTER PANEL WIDGETS
    var rowCenterHeader = Padding(
        padding: EdgeInsets.only(left: 5.0, top: 7.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Active Task', style: TextStyle(color: Color(0xFF9aa8b0), fontSize: 12.0)),
                  Padding(
                      padding:  EdgeInsets.only(top: 5.0),
                      child: Text((_selectedTask!=null? _selectedTask.location: ''), style: TextStyle(color: Colors.lightBlue, fontSize: 16.0), softWrap: false,))
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Task Type', style: TextStyle(color:  Color(0xFF9aa8b0), fontSize: 12.0)),
                  Padding(
                      padding:  EdgeInsets.only(top: 5.0),
                      child: Text(taskTypeDescr, style: TextStyle(color: Colors.white, fontSize: 16.0), softWrap: false))
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Task Status', style: TextStyle(color: Color(0xFF9aa8b0), fontSize: 12.0)),
                  Padding(
                      padding:  EdgeInsets.only(top: 5.0),
                      child: Text(taskStatusDescr,
                          style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)))
                ],
              ),
            ),
          ],
        ));

    var actionBoxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color:  Color(0xFFFFFFFF)),
        gradient: LinearGradient(
            colors: [ Color(0xFF81919D),  Color(0xFFAAB7BD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.repeated));


    Padding taskBody = null;

    if(_selectedTask!=null){
      if(_selectedTask.taskTypeID == 2){
        var requiredAction = Padding(
            padding: EdgeInsets.all(5.0),
            child: Container(
                decoration: actionBoxDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ImageIcon( AssetImage("assets/images/ic_barcode.png"), size: 60.0, color: Colors.white),
                    Center(
                        child: Text('Scan Machine',
                            style: TextStyle(
                                color:  Color(0xFFFFFFFF),
                                fontStyle: FontStyle.italic,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold)))
                  ],
                )));

        var taskInfo = Expanded(
            flex: 2,
            child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Container(
                    constraints: BoxConstraints.tightFor(height: 60.0),
                    decoration: actionBoxDecoration,
                    child: Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Text('Task Info',
                                style: TextStyle(
                                  color:  Color(0xFF444444),
                                  fontSize: 14.0,
                                ))),
                        Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Text('\$1723.00',
                                style:
                                TextStyle(color:  Color(0xFFFFFFFF), fontSize: 20.0, fontWeight: FontWeight.bold)))
                      ],
                    ))));

        var taskCustomer = Expanded(
            flex: 3,
            child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Container(
                    constraints: BoxConstraints.tightFor(height: 60.0),
                    decoration: actionBoxDecoration,
                    child: Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Text('Customer',
                                style: TextStyle(
                                  color:  Color(0xFF444444),
                                  fontSize: 14.0,
                                ))),
                        Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Text('Mike Walker',
                                style:
                                TextStyle(color:  Color(0xFFFFFFFF), fontSize: 20.0, fontWeight: FontWeight.bold)))
                      ],
                    ))));

        taskBody = Padding(
          padding: EdgeInsets.only(left: 25.0, top: 5.0, right: 25.0, bottom: 5.0),
          child: Column(
            children: <Widget>[
              Row(
                children: (_selectedTask!=null ? <Widget>[taskInfo, taskCustomer] :  <Widget>[]),
              ),
              Flexible(
                  child: requiredAction
              )
            ],
          ),
        );
      }

      else{ //other task type
        taskBody = Padding(
          padding: EdgeInsets.only(left: 25.0, top: 5.0, right: 25.0, bottom: 5.0),
          child: Text('Task type under development'),
        );
      }

    }



    var centerPanel = Flexible(
      flex: 4,
      child: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints.expand(height: 70.0),
            decoration: defaultHeaderDecoration,
            child: rowCenterHeader,
          ),
          Expanded(
            child: _selectedTask!=null? taskBody: Center(child: Text('Select a Task', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),))
          )
        ],
      ),
    );


    DateTime _timeDt = _selectedTask!=null? _selectedTask.taskCreated : null;
    String _timeStr = null;

    if(_timeDt !=null){

      Duration difference = DateTime.now().difference(_timeDt);

      var mins = difference.inMinutes.toString().padLeft(2, '0');
      var secs = (difference.inSeconds - (difference.inMinutes*60)).toString().padLeft(2, '0');

      _timeStr = '${mins}:${secs}';
    }

    //RIGHT PANEL WIDGETS
    var timerWidget = Padding(
      padding: EdgeInsets.only(top: 7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Time Taken', style: TextStyle(color: Colors.grey, fontSize: 12.0)),
          VizTimer(timeStarted: _timeStr)
        ],
      ),
    );



    Column rightActionWidgets;

    if(_selectedTask != null){
      rightActionWidgets = Column(
        children: <Widget>[
          VizTaskActionButton('Complete', [Color(0xFF6EBD24), Color(0xFF6EBD24)], onTapCallback: () => print('Complete')),
          VizTaskActionButton('Cancel', [Color(0xFFFF6600), Color(0xFFFFE100)], onTapCallback: () => print('Cancel')),
          VizTaskActionButton('Escalate', [Color(0xFF433177), Color(0xFFF2003C)], onTapCallback: () => print('Escalate'))
        ],
      );
    }
    else{
      rightActionWidgets = Column();
    }


    var rightPanel = Flexible(
      flex: 1,
      child: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints.expand(height: 70.0),
            decoration: defaultHeaderDecoration,
            child: timerWidget,
          ),
          Expanded(
            child: rightActionWidgets,
          )
        ],
      ),
    );

    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF586676), Color(0xFF8B9EA7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                tileMode: TileMode.repeated)),
        child: Row(
          children: <Widget>[leftPanel, centerPanel, rightPanel],
        ));
  }



}
