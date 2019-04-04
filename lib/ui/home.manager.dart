
import 'package:flutter/material.dart';
import 'package:techviz/components/vizSummaryHeader.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/managerViewPresenter.dart';
import 'package:techviz/ui/home.dart';

class HomeManager extends StatefulWidget {
  HomeManager(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeManagerState();
}

class HomeManagerState extends State<HomeManager> implements TechVizHome, IManagerViewPresenter {

  Widget _openTasks;
  Widget _teamAvailability;
  Widget _slotFloor;

  ManagerViewPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _presenter = ManagerViewPresenter(this);
    _presenter.loadOpenTasks();
    _presenter.loadTeamAvailability();
    _presenter.loadSlotFloorSummary();

  }


  @override
  Widget build(BuildContext context) {

    BoxDecoration boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Color(0xFFFFFFFF)),
        gradient: LinearGradient(colors: [Color(0xFF81919D), Color(0xFFAAB7BD)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated));


    Column column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: (Container(decoration: boxDecoration, child: Center(child: _openTasks != null ? _openTasks : CircularProgressIndicator())))),
        SizedBox(height: 5),
        Expanded(child: (Container(decoration: boxDecoration, child: Center(child: _teamAvailability != null ? _teamAvailability : CircularProgressIndicator())))),
        SizedBox(height: 5),
        Expanded(child: (Container(decoration: boxDecoration, child: Center(child: _slotFloor = _slotFloor!=null ? _slotFloor : CircularProgressIndicator())))),
      ],
    );

    Container container = Container(
      child: Padding(child: column, padding: EdgeInsets.all(5.0)),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
    );

    return container;

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
  void onOpenTasksLoaded(VizSummaryHeader summaryHeader) {
    if (this.mounted) {
      setState(() {
        _openTasks = summaryHeader;
      });
    }
  }

  @override
  void onSlotFloorSummaryLoaded(VizSummaryHeader summaryHeader) {
    if (this.mounted) {
      setState(() {
        _teamAvailability = summaryHeader;
      });
    }
  }

  @override
  void onTeamAvailabilityLoaded(VizSummaryHeader summaryHeader) {
    if (this.mounted) {
      setState(() {
        _slotFloor = summaryHeader;
      });
    }
  }

}