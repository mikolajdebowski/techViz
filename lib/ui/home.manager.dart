import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/components/vizListViewRow.dart';
import 'package:techviz/components/vizSummary.dart';
import 'package:techviz/model/dataEntry.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/managerViewPresenter.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/ui/home.dart';
import 'package:techviz/ui/reassignTask.dart';

import 'machineReservation.dart';

class HomeManager extends StatefulWidget {
  HomeManager(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeManagerState();
}

class HomeManagerState extends State<HomeManager> implements TechVizHome, IManagerViewPresenter {
  ManagerViewPresenter _presenter;

  List<DataEntryGroup> _openTasksList;
  List<DataEntryGroup> _teamAvailabilityList;
  List<DataEntryGroup> _slotFloorList;
  ScrollController _mainController;

  bool _openTasksLoading;
  bool _slotFloorLoading;

  @override
  void initState() {
    super.initState();

    _presenter = ManagerViewPresenter(this);
    _presenter.loadOpenTasks();
    _presenter.loadTeamAvailability();
    _presenter.loadSlotFloorSummary();

    _mainController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
      child: SingleChildScrollView(
        controller: _mainController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            VizSummary('OPEN TASKS', _openTasksList, onSwipeLeft: onOpenTasksSwipeLeft(), onSwipeRight: onOpenTasksSwipeRight(), onMetricTap: onOpenTasksMetricTap, isProcessing:  _openTasksLoading, onScroll: _onChildScroll),
            VizSummary('TEAM AVAILABILITY', _teamAvailabilityList,onSwipeLeft: onTeamAvailiblitySwipeLeft(), onScroll: _onChildScroll),
            VizSummary('SLOT FLOOR', _slotFloorList, onSwipeRight: onSlotFloorSwipeRight(), onSwipeLeft: onSlotFloorSwipeLeft(), onMetricTap: onSlotFloorMetricTap, isProcessing:  _slotFloorLoading, onScroll: _onChildScroll)
          ],
        ),
      ),
    );
  }

  void _onChildScroll(ScrollingStatus scroll){
    int maxOffset = 3;
    if(scroll==ScrollingStatus.ReachOnTop && _mainController.offset >= maxOffset){
      _mainController.jumpTo(_mainController.offset-maxOffset);
    }
    else if(scroll==ScrollingStatus.ReachOnBottom && _mainController.offset <= _mainController.position.maxScrollExtent-maxOffset) {
      _mainController.jumpTo(_mainController.offset+maxOffset);
    }
  }

  //OpenTasks
  SwipeAction onOpenTasksSwipeLeft(){ //action of the right of the view
    return SwipeAction('Re-assign to others', (dynamic entry){

      DataEntry dataEntry = (entry as DataEntry);
      String location = dataEntry.columns.where((DataEntryCell dataCell)=> dataCell.column == 'Location').toString();

      ReassignTask reassignTaskView = ReassignTask(dataEntry.id, location);

      Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (context) => reassignTaskView),
      ).then((bool isDone){
        if(isDone!=null && isDone){
            setState(() {
              _openTasksLoading = true;
              _openTasksList = null;
            });
            _presenter.loadOpenTasks();
          }
      });
    });
  }

  SwipeAction onOpenTasksSwipeRight(){

     Function reassignTaskCallback = (dynamic entry){

        DataEntry dataEntry = (entry as DataEntry);

        GlobalKey dialogKey = GlobalKey();
        VizDialogButton btnYes = VizDialogButton('Yes', (){

          _presenter.reassign(dataEntry.id, Session().user.userID).then((dynamic d){

            Navigator.of(dialogKey.currentContext).pop(true);
            setState(() {
              _openTasksLoading = true;
              _openTasksList = null;
            });
            _presenter.loadOpenTasks();

          });
        });

        VizDialogButton btnNo = VizDialogButton('No', (){
          Navigator.of(dialogKey.currentContext).pop(true);
        }, highlighted: false);

        VizDialog.Confirm(dialogKey, context, 'Re-assign task', 'Are you sure you want to re-assign the task to yourself?', actions: [btnNo, btnYes]);
    };


    //action of the left of the view
    return SwipeAction('Re-assign to myself', reassignTaskCallback);
  }
  void onOpenTasksMetricTap(){
    setState(() {
      _openTasksLoading = true;
    });
    _presenter.loadOpenTasks();
  }


  //TeamAvailiblity
  SwipeAction onTeamAvailiblitySwipeLeft(){
    return SwipeAction('Change Status',(dynamic entry){
      VizDialog.Alert(context, 'Change user\' status', 'Opens Change user\' status');
    });
  }



  //SlotFloor
  SwipeAction onSlotFloorSwipeRight(){

    Function onSlotActionButtonClickedCallback = (dynamic entry) {
      DataEntry dataEntry = (entry as DataEntry);
      String standID = dataEntry.id;

      MachineReservation machineReservationContent = MachineReservation(standID: standID);

      Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(builder: (BuildContext context) => machineReservationContent)).then((dynamic result) {
        if (result != null) {
          setState(() {
            _slotFloorLoading = true;
            _slotFloorList = null;
          });
          _presenter.loadSlotFloorSummary();
        }
      });
    };

    return SwipeAction('Make a reservation', onSlotActionButtonClickedCallback);
  }

  SwipeAction onSlotFloorSwipeLeft(){
    Function onSlotActionButtonClickedCallback = (dynamic entry) {
      DataEntry dataEntry = (entry as DataEntry);
      String standID = dataEntry.id;

      showDialog<bool>(context: context, builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text('Cancel reservation'),
          content: Text("Cancel reservation for ${standID}?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      }).then((bool cancel){
        if(cancel){
          final Flushbar _loadingBar = VizDialog.LoadingBar(message: 'Cancelling reservation...');
          _loadingBar.show(context);

          Repository().slotFloorRepository.cancelReservation(standID).then((dynamic result) {
            setState(() {
              _slotFloorLoading = true;
              _slotFloorList = null;
            });
            _presenter.loadSlotFloorSummary();

            _loadingBar.dismiss();
          }).catchError((dynamic error){
            _loadingBar.dismiss();
          });
        }
      });
    };
    return SwipeAction('Remove reservation', onSlotActionButtonClickedCallback);
  }

  void onSlotFloorMetricTap(){
    setState(() {
      _slotFloorLoading = true;
    });
    _presenter.loadSlotFloorSummary();
  }

  @override
  void onOpenTasksLoaded(List<DataEntryGroup> list) {
    if (this.mounted) {
      setState(() {
        _openTasksLoading = false;
        _openTasksList = list;
      });
    }
  }

  @override
  void onSlotFloorSummaryLoaded(List<DataEntryGroup> list) {
    if (this.mounted) {
      setState(() {
        _slotFloorLoading = false;
        _slotFloorList = list;
      });
    }
  }

  @override
  void onTeamAvailabilityLoaded(List<DataEntryGroup> list) {
    if (this.mounted) {
      setState(() {
        _teamAvailabilityList = list;
      });
    }
  }

  @override
  void onLoadError(dynamic error) {
    // TODO: implement onLoadError
  }





  //MASTERVIEW EVENTS
  @override
  void onUserSectionsChanged(Object obj) {
    // TODO: implement onUserSectionsChanged
  }

  @override
  void onUserStatusChanged(UserStatus us) {
    // TODO: implement onUserStatusChanged
  }
}

