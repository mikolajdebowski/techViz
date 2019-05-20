import 'package:flutter/material.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/components/vizSummary.dart';
import 'package:techviz/model/dataEntry.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/managerViewPresenter.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/ui/home.dart';
import 'package:techviz/ui/reassignTask.dart';

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
            VizSummary('OPEN TASKS', _openTasksList, onSwipeLeft: onOpenTasksSwipeLeft(), onSwipeRight: onOpenTasksSwipeRight(), onMetricTap: onOpenTasksMetricTap, isProcessing:  _openTasksLoading),
            VizSummary('TEAM AVAILABILITY', _teamAvailabilityList,onSwipeLeft: onTeamAvailiblitySwipeLeft()),
            VizSummary('SLOT FLOOR', _slotFloorList)
          ],
        ),
      ),
    );
  }

  void onOpenTasksMetricTap(){
    setState(() {
      _openTasksLoading = true;
    });
    _presenter.loadOpenTasks();
  }

  SwipeAction onOpenTasksSwipeLeft(){ //action of the right of the view
    return SwipeAction('Re-assign to others', '<<<', (dynamic entry){

      DataEntry dataEntry = (entry as DataEntry);
      String location = dataEntry.columns['Location'].toString();

      ReassignTask reassignTaskView = ReassignTask(dataEntry.id, location);

      Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (context) => reassignTaskView),
      ).then((bool isDone){
        if(isDone!=null && isDone){
            setState(() {
              _openTasksLoading = true;
            });
            _presenter.loadOpenTasks();
          }
      });
    });
  }

  SwipeAction onOpenTasksSwipeRight(){ //action of the left of the view
    return SwipeAction('Re-assign to myself', '>>>',(dynamic entry){

      GlobalKey dialogKey = GlobalKey();
      DataEntry dataEntry = (entry as DataEntry);
      VizDialogButton btnYes = VizDialogButton('Yes', (){

        _presenter.reassign(dataEntry.id, Session().user.userID).then((dynamic d){

          Navigator.of(dialogKey.currentContext).pop(true);
          setState(() {
            _openTasksLoading = true;
          });
          _presenter.loadOpenTasks();

        });
      });

      VizDialogButton btnNo = VizDialogButton('No', (){
        Navigator.of(dialogKey.currentContext).pop(true);
      }, highlighted: false);

      VizDialog.Confirm(dialogKey, context, 'Re-assign task', 'Are you sure you want to re-assign the task to yourself?', actions: [btnNo, btnYes]);

    });
  }

  SwipeAction onTeamAvailiblitySwipeLeft(){
    return SwipeAction('Change Status', '<<<',(dynamic entry){
      VizDialog.Alert(context, 'Change user\' status', 'Opens Change user\' status');
    });
  }

  @override
  void onUserSectionsChanged(Object obj) {
    // TODO: implement onUserSectionsChanged
  }

  @override
  void onUserStatusChanged(UserStatus us) {
    // TODO: implement onUserStatusChanged
  }

  @override
  void onLoadError(dynamic error) {
    // TODO: implement onLoadError
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
}

