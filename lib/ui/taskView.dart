import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:techviz/components/taskList/VizTaskItem.dart';
import 'package:techviz/bloc/taskViewBloc.dart';
import 'package:techviz/components/vizTaskActionButton.dart';
import 'package:techviz/components/vizTimer.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/ui/home.dart';
import 'escalation.dart';

class TaskView extends StatefulWidget {
  const TaskView(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() => TaskViewState();
}

class TaskViewState extends State<TaskView> with WidgetsBindingObserver implements TechVizHome {
  bool _isLoadingTasks = false;
  String _taskListStatusIcon = "assets/images/ic_processing.png";

  Task _selectedTask;
  //Observable<Task> _taskList;// = [];
  StreamSubscription<List<Task>> streamSubscription;
  StreamConsumer<Task> consumer = StreamConsumer<Task>();

  final defaultHeaderDecoration = BoxDecoration(
      border: Border.all(color: Colors.black, width: 0.5),
      gradient: LinearGradient(
          colors: const [Color(0xFF4D4D4D), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.repeated));

  @override
  void initState() {
    streamSubscription = TaskViewBloc().stream..listen(onTaskReceived, onError: onTaskListenError);

    Timer.periodic(Duration(milliseconds: 500), (Timer timer) {
      String tick = timer.tick.toString();
      Task task = Task(id: tick, location: tick);
      TaskViewBloc().update(task);
    });


    Future.delayed(Duration(seconds: 10), (){
      streamSubscription?.cancel();
    });

    Future.delayed(Duration(seconds: 20), (){
      setState(() {
        streamSubscription = TaskViewBloc().stream.listen(onTaskReceived, onError: onTaskListenError);
      });
    });

    super.initState();
  }

  void onTaskReceived(Task task) {
    setState(() {
      streamSubscription.on
      print(task.id);
    });
  }

  void onTaskListenError(dynamic error) {
    print('onError' + error.toString());
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  List<Widget> get taskItems {
    List<VizTaskItem> output = [];

//    _taskList.asMap().forEach((int i, Task task) {
//      output.add(
//          VizTaskItem(task.id, task.location, i, onTaskItemTapCallback, _selectedTask != null && _selectedTask.id == task.id, task.urgencyHEXColor));
//    });

    return output;
  }











  @override
  Widget build(BuildContext context) {


    String taskTextStr = 'No tasks';//_taskList.isEmpty ? 'No tasks' : (_taskList.length == 1 ? '1 Task' : '${_taskList.length} Tasks');

    int idx = 1;
    StreamBuilder<Task>(
        stream: TaskViewBloc().stream,
        builder: (context, AsyncSnapshot<Task> snapshot){
          if(snapshot.hasData==false){
            return Container();
          }
          if(snapshot.hasData){
            Task task = snapshot.data;
            return VizTaskItem(task.id, task.location, idx++, onTaskItemTapCallback, _selectedTask != null && _selectedTask.id == task.id, task.urgencyHEXColor);
          }
    });


    Widget listContainer = _taskList.isEmpty
        ? Container()
        : ListView(
            children: taskItems,
          );

    //TASK PANEL
    Flexible tasksPanel = Flexible(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Text('Priority', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                    ImageIcon(AssetImage("assets/images/ic_arrow_up.png"), size: 20.0, color: Colors.grey)
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(border: Border(right: BorderSide(color: Color(0x33000000)))),
              child: listContainer,
            ),
          )
        ],
      ),
    );

    //CENTER PANEL WIDGETS
    Padding rowCenterHeader = Padding(
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
                        _selectedTask != null ? _selectedTask.location : '',
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
                  Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Text(_selectedTask != null ? _selectedTask.taskType.description : '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                          softWrap: false))
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
                      child: Text(_selectedTask != null ? _selectedTask.taskStatus.description : '',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)))
                ],
              ),
            ),
          ],
        ));

    BoxDecoration actionBoxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Color(0xFFFFFFFF)),
        gradient: LinearGradient(
            colors: const [Color(0xFF81919D), Color(0xFFAAB7BD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.repeated));

    Widget taskBody;

    if (_selectedTask != null) {
      String mainActionImageSource;
      String mainActionTextSource;
      VoidCallback actionCallBack;

      bool btnEnabled = _selectedTask.dirty == false;

      if (_selectedTask.taskStatus.id == 1) {
        mainActionImageSource = "assets/images/ic_acknowledge.png";
        mainActionTextSource = 'Acknowledge';
        actionCallBack = () {
          if (btnEnabled) updateTaskStatus("2");
        };
      } else if (_selectedTask.taskStatus.id == 2) {
        mainActionImageSource = "assets/images/ic_cardin.png";
        mainActionTextSource = 'Card in';
        actionCallBack = () {
          if (btnEnabled) updateTaskStatus("3");
        };
      } else if (_selectedTask.taskStatus.id == 3) {
        mainActionImageSource = "assets/images/ic_complete.png";
        mainActionTextSource = 'Complete';
        actionCallBack = () {
          if (btnEnabled) updateTaskStatus("13");
        };
      }

      ImageIcon mainActionIcon = ImageIcon(AssetImage(mainActionImageSource), size: 60.0, color: btnEnabled ? Colors.white : Colors.white30);
      Center mainActionText = Center(
          child: Text(mainActionTextSource,
              style: TextStyle(
                  color: btnEnabled ? Colors.white : Colors.white30, fontStyle: FontStyle.italic, fontSize: 20.0, fontWeight: FontWeight.bold)));

      Padding requiredAction = Padding(
          padding: EdgeInsets.all(2.0),
          child: GestureDetector(
            onTap: actionCallBack,
            child: Container(
                decoration: actionBoxDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[mainActionIcon, mainActionText],
                )),
          ));

      String taskInfoDescription = '';
      if (_selectedTask != null) {
        if (_selectedTask.amount > 0) {
          taskInfoDescription = '${_selectedTask.amount.toStringAsFixed(2)}';
        } else {
          taskInfoDescription = _selectedTask.eventDesc;
        }
      }

      Expanded taskInfo = Expanded(
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

        if (_selectedTask.playerID != null && _selectedTask.playerID.isNotEmpty) {
          String playerName = '${_selectedTask.playerFirstName} ${_selectedTask.playerLastName}';

          BoxDecoration boxDecoForTierWidget;
          String tier = _selectedTask.playerTier;
          String tierColorHexStr = _selectedTask.playerTierColorHEX;
          if (tier != null && tierColorHexStr != null) {
            tierColorHexStr = tierColorHexStr.replaceAll('#', '');
            Color hexColor = Color(int.parse('0xFF$tierColorHexStr'));
            boxDecoForTierWidget = BoxDecoration(borderRadius: BorderRadius.circular(6.0), color: hexColor);
          } else {
            boxDecoForTierWidget = BoxDecoration(borderRadius: BorderRadius.circular(6.0), border: Border.all(color: Colors.white));
          }

          Align playerTierWidget = Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.all(2.0),
              child: Container(
                width: 10.0,
                decoration: boxDecoForTierWidget,
              ),
            ),
          );

          Align playerDetailsWidget = Align(
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
                  Padding(
                      padding: EdgeInsets.only(top: 3.0),
                      child: Text(playerName,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Color(0xFFFFFFFF), fontSize: playerName.length > 20 ? 12.0 : 14.0, fontWeight: FontWeight.bold)))
                ],
              ));

          Expanded taskCustomer = Expanded(
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

    Flexible centerPanel = Flexible(
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
                      _taskList..isEmpty ? taskTextStr : 'Select a Task',
                      style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                    )))
        ],
      ),
    );

    //RIGHT PANEL WIDGETS
    Padding timerWidget = Padding(
      padding: EdgeInsets.only(top: 7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Time Taken', style: TextStyle(color: Colors.grey, fontSize: 12.0)),
          VizTimer(timeStarted: _selectedTask != null ? _selectedTask.taskCreated : null)
        ],
      ),
    );

    List<VizTaskActionButton> rightActionWidgets = <VizTaskActionButton>[];
    if (_selectedTask != null) {
      bool enableButtons = _selectedTask.dirty == false;
      if (_selectedTask.taskStatus.id == 2 || _selectedTask.taskStatus.id == 3) {
        rightActionWidgets.add(VizTaskActionButton('Cancel', const [Color(0xFF433177), Color(0xFFF2003C)], enabled: enableButtons, onTapCallback: () {
          _showCancellationDialog(_selectedTask.id);
        }));
      }

      if (_selectedTask.taskStatus.id == 3) {
        rightActionWidgets
            .add(VizTaskActionButton('Escalate', const [Color(0xFF1356ab), Color(0xFF23ABE7)], enabled: enableButtons, onTapCallback: () {
          _goToEscalationPathView();
        }));
      }
    }

    Column rightActionsColumn = Column(children: rightActionWidgets);

    Flexible rightPanel = Flexible(
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

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: const [Color(0xFF586676), Color(0xFF8B9EA7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  tileMode: TileMode.repeated)),
          child: Row(
            children: <Widget>[tasksPanel, centerPanel, rightPanel],
          ),
        ));
  }

  void taskUpdateCallback(String taskID) {
    //_loadingBar.dismiss();
    //_taskViewPresenter.loadTaskList(Session().user.userID);
  }

  void updateTaskStatus(String statusID) {
    //_loadingBar.show(context);
    //Repository().taskRepository.update(_selectedTask.id, taskStatusID: statusID, callBack: taskUpdateCallback);
  }

  void bindTaskListener() async {
    await unTaskBindListener();

//    _streamController = Repository().taskRepository.listenQueue((Task task) {
//      if (task == null) {
//        return;
//      }
//
//      Session session = Session();
//      if ([1, 2, 3].toList().contains(task.taskStatus.id) && task.userID == session.user.userID) {
//        //update the view
//        if (_selectedTask != null && _selectedTask.id == task.id) {
//          setState(() {
//            _selectedTask = task;
//          });
//        }
//      } else {
//        //remove from the view
//        if (_selectedTask != null && _selectedTask.id == task.id) {
//          setState(() {
//            _selectedTask = null;
//          });
//        }
//      }
//      //_taskViewPresenter.loadTaskList(session.user.userID);
//    }, (dynamic error) {
//      print(error);
//    });
  }

  Future unTaskBindListener() async {
    //if (_streamController == null || !_streamController.isClosed) {
    //   return;
    //}
    //await _streamController.close();
  }

  void onTaskItemTapCallback(String taskID) {
    if (!mounted) return;

    setState(() {
      //  _selectedTask = _taskList.where((Task task) => task.id == taskID).first;
    });
  }

  void reloadTasks() {
    if (!mounted) return;

    setState(() {
      _isLoadingTasks = true;
      _selectedTask = null;
    });

//    Repository().taskRepository.fetch().then((dynamic b) {
//      Session session = Session();
//      _taskViewPresenter.loadTaskList(session.user.userID);
//    });
  }

  void _showCancellationDialog(final String taskID) {
    final TextEditingController _cancellationController = TextEditingController();

    bool btnEnbled = true;
    double _width = MediaQuery.of(context).size.width / 100 * 80;
    String location = _selectedTask.location.toString();

    Container container = Container(
      width: _width,
      decoration: BoxDecoration(shape: BoxShape.rectangle),
      child: SingleChildScrollView(
        child: Form(
          key: _cancellationFormKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Text('Cancel Task $location'),
              ),
              Divider(
                color: Colors.grey,
                height: 4.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextFormField(
                  controller: _cancellationController,
                  maxLength: 4000,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "Cancellation reason",
                    border: InputBorder.none,
                  ),
                  maxLines: 6,
                  validator: (String value) {
                    if (value.isEmpty) return 'Please inform the cancellation reason';
                  },
                ),
              ),
              Divider(
                color: Colors.grey,
                height: 4.0,
              ),
              Stack(
                children: <Widget>[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          "Dismiss",
                        ),
                      )),
                  Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        onPressed: () {
                          if (!btnEnbled) return;

                          if (!_cancellationFormKey.currentState.validate()) {
                            return;
                          }

                          btnEnbled = false;

                          //_loadingBar.show(context);
//                          Repository().taskRepository.update(taskID, taskStatusID: '12', cancellationReason: _cancellationController.text,
//                              callBack: (String result) {
//                            _loadingBar.dismiss();
//                            Navigator.of(context).pop(true);
//                          }).catchError((dynamic error) {
//                            _loadingBar.dismiss();
//
//                            VizDialog.Alert(context, "Error", error.toString()).then((bool dialogResult) {
//                              if (error.runtimeType == TaskNotAvailableException) {
//                                Navigator.of(context).pop(false);
//                              }
//                            });
//                            btnEnbled = true;
//                          });
                        },
                        child: Text(
                          "Cancel this task",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );

    showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: container,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          );
        }).then((bool canceled) {
      if (canceled) reloadTasks();
    });
  }

  void _goToEscalationPathView() {
    if (_selectedTask == null) return;

    String id = _selectedTask.id;
    String location = _selectedTask.location;

    EscalationForm escalationForm = EscalationForm(id, location, (bool result) {
      if (result) reloadTasks();
    });

    MaterialPageRoute<bool> mpr = MaterialPageRoute<bool>(builder: (BuildContext context) => escalationForm);
    Navigator.of(context).push(mpr);
  }

  final GlobalKey<FormState> _cancellationFormKey = GlobalKey<FormState>();

  @override
  void onUserStatusChanged(UserStatus us) {
    reloadTasks();
  }

  @override
  void onUserSectionsChanged(List<UserSection> sections) {
    reloadTasks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //bindTaskListener();
      //reloadTasks();
    }
  }
}
