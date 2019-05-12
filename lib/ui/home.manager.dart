import 'package:flutter/material.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/components/vizSummary.dart';
import 'package:techviz/model/dataEntry.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/managerViewPresenter.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/ui/home.dart';

class HomeManager extends StatefulWidget {
  HomeManager(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeManagerState();
}

class HomeManagerState extends State<HomeManager> implements TechVizHome, IManagerViewPresenter {
  ManagerViewPresenter _presenter;

  List<DataEntry> _openTasksList;
  List<DataEntry> _teamAvailabilityList;
  List<DataEntry> _slotFloorList;
  ScrollController _mainController;

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
            VizSummary('OPEN TASKS', _openTasksList, ['Status'], onSwipeLeft: onOpenTasksSwipeLeft(), onSwipeRight: onOpenTasksSwipeRight()),
            VizSummary('TEAM AVAILABILITY', _teamAvailabilityList, ['Status'], onSwipeLeft: onTeamAvailiblitySwipeLeft()),
            VizSummary('SLOT FLOOR', _slotFloorList, ['Status'])
          ],
        ),
      ),
    );
  }


  SwipeAction onOpenTasksSwipeLeft(){
    return SwipeAction('Re-assign to others', '<<<', (dynamic entry){

      DataEntry dataEntry = (entry as DataEntry);
      String location = dataEntry.columns['Location'] as String;

      VizDialog.Alert(context, 'Reassign To others', 'Reassign to others location $location');
    });
  }

  SwipeAction onOpenTasksSwipeRight(){
    return SwipeAction('Re-assign to myself', '>>>',(dynamic entry){

      GlobalKey dialogKey = GlobalKey();

      DataEntry dataEntry = (entry as DataEntry);
      String location = dataEntry.columns['Status'] as String;

      VizDialogButton btnYes = VizDialogButton('Yes', (){
        _presenter.reassign('<TASKID>', Session().user.userID).then((dynamic d){
          Navigator.of(dialogKey.currentContext).pop(true);
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
  void onOpenTasksLoaded(List<DataEntry> summaryList) {
    if (this.mounted) {
      setState(() {
        _openTasksList = summaryList;
      });
    }
  }

  @override
  void onSlotFloorSummaryLoaded(List<DataEntry> summaryList) {
    if (this.mounted) {
      setState(() {
        _slotFloorList = summaryList;
      });
    }
  }

  @override
  void onTeamAvailabilityLoaded(List<DataEntry> summaryList) {
    if (this.mounted) {
      setState(() {
        _teamAvailabilityList = summaryList;
      });
    }
  }
}
