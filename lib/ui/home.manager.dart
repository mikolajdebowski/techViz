import 'package:flutter/material.dart';
import 'package:techviz/components/VizAlert.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/components/vizSummary.dart';
import 'package:techviz/model/dataEntry.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/managerViewPresenter.dart';
import 'package:techviz/ui/home.dart';

class HomeManager extends StatefulWidget {
  HomeManager(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeManagerState();
}

class HomeManagerState extends State<HomeManager> implements TechVizHome, IManagerViewPresenter, VizSummaryActions {
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
            VizSummary('OPEN TASKS', _openTasksList, ['Status'], onSwipeLeft: onOpenTasksSwipeLeft(), onSwipeRight: onOpenTasksSwipeRight(), summaryActions: this, key: GlobalKey()),
            VizSummary('TEAM AVAILABILITY', _teamAvailabilityList, ['Status'], onSwipeLeft: onTeamAvailiblitySwipeLeft(), summaryActions: this,  key: GlobalKey()),
            VizSummary('SLOT FLOOR', _slotFloorList, ['Status'], summaryActions: this,  key: GlobalKey())
          ],
        ),
      ),
    );
  }


  SwipeAction onOpenTasksSwipeLeft(){
    return SwipeAction('Reassign to others', '<<<', (dynamic entry){

      DataEntry dataEntry = (entry as DataEntry);
      String location = dataEntry.columns['Location'] as String;

      VizDialog.Alert(context, 'Reassign To others', 'Reassign to others location $location');
    });
  }

  SwipeAction onOpenTasksSwipeRight(){
    return SwipeAction('Reassign to myself', '>>>',(dynamic entry){

      DataEntry dataEntry = (entry as DataEntry);
      String location = dataEntry.columns['Status'] as String;

      VizDialog.Alert(context, 'Reassign To myself', 'Reassign myself location $location');

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

  @override
  void onSummaryPanelCollapsed(GlobalKey summary) {
    RenderBox renderBox = summary.currentContext.findRenderObject();
    print('collapsed');
  }

  @override
  void onSummaryPanelExpanded(GlobalKey summary) {
    RenderBox renderBox = summary.currentContext.findRenderObject();
    //Offset offset = renderBox.localToGlobal(Offset.zero);
    //_mainController.animateTo(offset.dy-80, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    print('expanded');
  }
}
