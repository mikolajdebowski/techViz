import 'package:flutter/material.dart';
import 'package:techviz/components/vizTaskActionButton.dart';
import 'package:techviz/components/vizTimer.dart';
import 'package:techviz/home.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/taskListPresenter.dart';
import 'package:techviz/repository/rabbitmq/queue/taskQueue.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/repository/taskRepository.dart';

class AttendantHome extends StatefulWidget {

  AttendantHome(Key key): super(key:key);

  @override
  State<StatefulWidget> createState() => AttendantHomeState();
}

class AttendantHomeState extends State<AttendantHome> implements ITaskListPresenter<Task>, HomeEvents {
  bool _isUserOnline = false;
  bool _isLoadingTasks = false;
  TaskListPresenter _taskPresenter;
  Task _selectedTask = null;
  List<Task> _taskList = [];
  var _taskListStatusIcon = "assets/images/ic_processing.png";

  @override
  initState() {
    _taskList = [];
    _taskPresenter = TaskListPresenter(this);
    _taskListStatusIcon = "assets/images/ic_processing.png";

    super.initState();
  }


  @override
  void onTaskListLoaded(List<Task> result) {
    setState(() {
      _taskList = result;
      _taskListStatusIcon = null;
      _isLoadingTasks = false;
    });
  }

  @override
  void onLoadError(Error error) {
    // TODO: implement onLoadError
  }



  @override
  Widget build(BuildContext context) {
    final defaultHeaderDecoration = BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
        gradient: LinearGradient(colors: [Color(0xFF4D4D4D), Color(0xFF000000)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated));

    //LEFT PANEL WIDGETS
    //task list header and task list

    void _onTaskItemTapped(Task task) {
      setState(() {
        _selectedTask = task;
      });
    }

    var listTasks = <Widget>[];

    for (var i = 1; i <= _taskList.length; i++) {
      Task task = _taskList[i - 1];
      var taskItem = GestureDetector(
          onTap: () {
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
                          colors: _selectedTask!= null && _selectedTask.id == task.id ? [Color(0xFF65b1d9), Color(0xFF0268a2)] : [Color(0xFF45505D), Color(0xFF282B34)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          tileMode: TileMode.repeated)),
                  child: Center(child: Text(i.toString(), style: TextStyle(color: Colors.white))),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  height: 60.0,
                  decoration:
                      BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFB2C7CF), Color(0xFFE4EDEF)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
                  child: Center(
                      child: Text(
                    task.location,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
                  )),
                ),
              ),
            ],
          ));

      listTasks.add(taskItem);
    }


    var taskTextStr = listTasks.length == 0 ? 'No tasks' : (listTasks.length == 1 ? '1 Task' : '${listTasks.length} Tasks');

    Widget listContainer = Center(child: null);

    if(_isLoadingTasks){
      listContainer = Center(child: CircularProgressIndicator());
    }
    else if (listTasks != null && listTasks.length > 0) {
      //list container
      listContainer = ListView(
        children: listTasks,
      );
    }

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
                          child: _taskListStatusIcon != null ? ImageIcon(AssetImage(_taskListStatusIcon), size: 15.0, color: Colors.blueGrey) : null,
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
                      padding: EdgeInsets.only(top: 5.0),
                      child: Text(
                        (_selectedTask != null ? _selectedTask.location : ''),
                        style: TextStyle(color: Colors.lightBlue, fontSize: 20.0),
                        softWrap: false,
                      ))
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Task Type', style: TextStyle(color: Color(0xFF9aa8b0), fontSize: 12.0)),
                  Padding(padding: EdgeInsets.only(top: 5.0), child: Text(_selectedTask!= null ? _selectedTask.taskType.description : '', maxLines: 2, overflow:TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16.0), softWrap: false))
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Task Status', style: TextStyle(color: Color(0xFF9aa8b0), fontSize: 12.0)),
                  Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Text(_selectedTask!=null ? _selectedTask.taskStatus.description : '', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)))
                ],
              ),
            ),
          ],
        ));

    var actionBoxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Color(0xFFFFFFFF)),
        gradient: LinearGradient(colors: [Color(0xFF81919D), Color(0xFFAAB7BD)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated));

    Widget taskBody;


    void taskUpdateCallback(String taskID) {

        Session session = Session();
        TaskRepository().getTask(taskID).then((Task task){
          setState(()  {
            if([1,2,3].toList().contains(task.taskStatus.id)){
            _selectedTask = task;
            }
            else _selectedTask = null;
          });
          _taskPresenter.loadTaskList(session.user.UserID);
        });
    }



    if (_selectedTask != null) {

        String mainActionImageSource;
        String mainActionTextSource;
        VoidCallback actionCallBack;

        bool btnEnabled = _selectedTask.dirty == false;

        if (_selectedTask.taskStatus.id == 1) {
          mainActionImageSource = "assets/images/ic_acknowledge.png";
          mainActionTextSource = 'Acknowledge';
          actionCallBack = (){
            if(btnEnabled)
              TaskRepository().update(_selectedTask.id, taskStatusID: "2", callBack: taskUpdateCallback, updateRemote: true);
          };
        } else if (_selectedTask.taskStatus.id == 2) {
          mainActionImageSource = "assets/images/ic_cardin.png";
          mainActionTextSource = 'Card in';
          actionCallBack = (){
            if(btnEnabled)
              TaskRepository().update(_selectedTask.id, taskStatusID: "3", callBack: taskUpdateCallback, updateRemote: true);
          };
        } else if (_selectedTask.taskStatus.id == 3) {
          mainActionImageSource = "assets/images/ic_complete.png";
          mainActionTextSource = 'Complete';
          actionCallBack = (){
            if(btnEnabled)
              TaskRepository().update(_selectedTask.id, taskStatusID: "13", callBack: taskUpdateCallback, updateRemote: true);
          };
        }

        ImageIcon mainActionIcon = ImageIcon(AssetImage(mainActionImageSource), size: 60.0, color: btnEnabled? Colors.white: Colors.white70);
        Center mainActionText = Center(child: Text(mainActionTextSource, style: TextStyle(color: btnEnabled? Colors.white: Colors.white70, fontStyle: FontStyle.italic, fontSize: 20.0, fontWeight: FontWeight.bold)));

        var requiredAction = Padding(
          padding: EdgeInsets.all(2.0),
          child: GestureDetector(
            onTap: actionCallBack,
            child: Container(
                decoration: actionBoxDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    mainActionIcon,mainActionText
                  ],
                )),
          )
      );

      String taskInfoDescription = '';
      if (_selectedTask != null) {
        if (_selectedTask.amount > 0) {
          taskInfoDescription = '${_selectedTask.amount.toStringAsFixed(2)}';
        } else {
          taskInfoDescription = _selectedTask.eventDesc;
        }
      }

      var taskInfo = Expanded(
          flex: 2,
          child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Container(
                  constraints: BoxConstraints.tightFor(height: 60.0),
                  decoration: actionBoxDecoration,
                  child: Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 3.0),
                          child: Text('Task Info',
                              style: TextStyle(
                                color: Color(0xFF444444),
                                fontSize: 14.0,
                              ))),
                      Padding(
                          padding: EdgeInsets.only(top: 5.0, left: 4.0),
                          child: Text(taskInfoDescription,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14.0, fontWeight: FontWeight.bold)))
                    ],
                  ))));

      List<Widget> taskDetailsHeader = <Widget>[];
      if (_selectedTask != null) {
        taskDetailsHeader.add(taskInfo);

        if (_selectedTask.playerID != null && _selectedTask.playerID.length > 0) {
          String playerName = '${_selectedTask.playerFirstName} ${_selectedTask.playerLastName}';

          BoxDecoration boxDecoForTierWidget = null;
          String tier = _selectedTask.playerTier;
          String tierColorHexStr = _selectedTask.playerTierColorHEX;
          if (tier != null && tierColorHexStr !=null) {
            tierColorHexStr = tierColorHexStr.replaceAll('#', '');
            var hexColor = Color(int.parse('0xFF${tierColorHexStr}'));
            boxDecoForTierWidget = BoxDecoration(borderRadius: BorderRadius.circular(6.0), color: hexColor);
          } else {
            boxDecoForTierWidget = BoxDecoration(borderRadius: BorderRadius.circular(6.0), border: Border.all(color: Colors.white));
          }

          var playerTierWidget = Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.all(2.0),
              child: Container(
                width: 10.0,
                decoration: boxDecoForTierWidget,
              ),
            ),
          );


          var playerDetailsWidget = Align(
              alignment: Alignment.center,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text('Customer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF444444),
                          fontSize: 14.0,
                        ))),
                Padding(padding: EdgeInsets.only(top: 3.0), child: Text(playerName, maxLines: 2, textAlign: TextAlign.center, overflow:TextOverflow.ellipsis, style: TextStyle(color: Color(0xFFFFFFFF), fontSize: (playerName.length > 20 ? 12.0 : 14.0), fontWeight: FontWeight.bold)))
              ],
            )
          );

          var taskCustomer = Expanded(
              flex: 3,
              child: Container(
                      margin: EdgeInsets.only(left: 2.0),
                      constraints: BoxConstraints.tightFor(height: 60.0),
                      decoration: actionBoxDecoration,
                      child: Stack(
                        children: <Widget>[playerDetailsWidget, playerTierWidget],
                      )));

          taskDetailsHeader.add(taskCustomer);
        }
      }

      taskBody = Padding(
        padding: EdgeInsets.only(left: 15.0, top: 5.0, right: 15.0, bottom: 5.0),
        child: Column(
          children: <Widget>[
            Row(
              children: taskDetailsHeader,
            ),
            Flexible(child: requiredAction)
          ],
        ),
      );
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
              child: _selectedTask != null
                  ? taskBody
                  : Center(
                      child: Text(
                      _taskList.length==0? '': 'Select a Task',
                      style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                    )))
        ],
      ),
    );

    //RIGHT PANEL WIDGETS
    var timerWidget = Padding(
      padding: EdgeInsets.only(top: 7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[Text('Time Taken', style: TextStyle(color: Colors.grey, fontSize: 12.0)), VizTimer(timeStarted: _selectedTask != null ? _selectedTask.taskCreated : null)],
      ),
    );

    void _showConfirmationDialogWithOptions(String title, VoidCallback callback){
      showDialog<bool>(context: context, builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title),
          content: Text("Are you sure?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                callback();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
    }

    List<VizTaskActionButton> rightActionWidgets = List<VizTaskActionButton>();
    if (_selectedTask != null) {

      bool enableButtons = _selectedTask.dirty == false;
      if (_selectedTask.taskStatus.id == 2 || _selectedTask.taskStatus.id == 3) {
        rightActionWidgets.add(VizTaskActionButton('Cancel', [Color(0xFF433177), Color(0xFFF2003C)], enabled: enableButtons, onTapCallback: () {
          _showConfirmationDialogWithOptions('Cancel a task', () {
           TaskRepository().update(_selectedTask.id, taskStatusID: "12", callBack: taskUpdateCallback, updateRemote: true);
          });
        }));
      }

      if (_selectedTask.taskStatus.id == 3) {
        rightActionWidgets.add(VizTaskActionButton('Escalate', [Color(0xFF1356ab), Color(0xFF23ABE7)], enabled: enableButtons, onTapCallback: () {
          _showConfirmationDialogWithOptions('Escalate a task', () {
            TaskRepository().update(_selectedTask.id, taskStatusID: "5", callBack: taskUpdateCallback, updateRemote: true);
          });
        }));
      }
    }

    Column rightActionsColumn = Column(children: rightActionWidgets);

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
            child: rightActionsColumn,
          )
        ],
      ),
    );

    return Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
        child: Row(
          children: <Widget>[leftPanel, centerPanel, rightPanel],
        ));
  }


  @override
  void onUserStatusChanged(UserStatus us) {
    if(us.isOnline){
      setState(() {
        _isLoadingTasks = true;
        _isUserOnline = us.isOnline;
      });

      loadTasks();
    }
    else{
      setState(() {
        _isLoadingTasks = false;
        _isUserOnline = us.isOnline;

        _taskList = List<Task>();
        _selectedTask = null;
      });

      TaskQueue().StopListening();
    }
  }

  @override
  void onUserSectionsChanged(Object obj) {
    if(_isUserOnline){
      loadTasks();
    }
  }

  void loadTasks(){
    setState(() {
      _isLoadingTasks = true;
    });

    Session session = Session();
    Repository().taskRepository.fetch().then((dynamic b){
      _taskPresenter.loadTaskList(session.user.UserID);
      TaskQueue().listen(taskInfoQueueCallback);
    });
  }


  void taskInfoQueueCallback(Task task) {
    Session session = Session();

    if(session.user==null)
      return;

    setState(() {
      if([1,2,3].toList().contains(task.taskStatus.id) && task.userID ==  session.user.UserID){ //update the view
        print(task.id + ' received with StatusID ' +task.taskStatus.id.toString());

        if(_selectedTask!=null && _selectedTask.id == task.id){
          _selectedTask = task;
          print(task.id + ' updated selected with StatusID ' +task.taskStatus.id.toString());
        }

        for(int i=0; i< _taskList.length; i++){
          if(_taskList[i].id == task.id){
            _taskList[i] = task;
            print(task.id + ' updated in the local list because StatusID is ' +task.taskStatus.id.toString());
          }
        }

        if(_taskList.where((Task thisTask) => task.id == thisTask.id).length==0){
          _taskList.add(task); //seems ok
          print(task.id + ' added to the list with StatusID ' +task.taskStatus.id.toString());

        }
      }
      else{ //remove from the view
        if(_selectedTask!=null && _selectedTask.id == task.id){
          _selectedTask = null;
          print(task.id + ' removed from selected because StatusID is ' +task.taskStatus.id.toString());
        }

        if(_taskList!=null && _taskList.length>0){
          _taskList = _taskList.where((Task thisTask) => thisTask.id != task.id).toList();
          print(task.id + ' removed from the list because StatusID is ' +task.taskStatus.id.toString());
        }
      }
    });
  }


}
