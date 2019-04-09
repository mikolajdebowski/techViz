import 'package:flutter/material.dart';
import 'package:techviz/components/vizSummary.dart';
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
  Widget _openTasksHeader;
  Widget _teamAvailabilityHeader;
  Widget _slotFloorHeader;

  Widget _openTasksList;
  Widget _teamAvailabilityList;
  Widget _slotFloorList;

  ManagerViewPresenter _presenter;

  String selectedTag;

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
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            VizSummary(header: _openTasksHeader, list: _openTasksList),
            VizSummary(header: _teamAvailabilityHeader, list: _teamAvailabilityList),
            VizSummary(header: _slotFloorHeader, list: _slotFloorList)
          ],
        ),
      ),
    );
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
        _openTasksHeader = summaryHeader;
      });
    }
  }

  @override
  void onSlotFloorSummaryLoaded(VizSummaryHeader summaryHeader) {
    if (this.mounted) {
      setState(() {
        _teamAvailabilityHeader = summaryHeader;
      });
    }
  }

  @override
  void onTeamAvailabilityLoaded(VizSummaryHeader summaryHeader) {
    if (this.mounted) {
      setState(() {
        _slotFloorHeader = summaryHeader;
      });
    }
  }



  @override
  void onOpenTasksExpanded(Widget listResult) {
    if (this.mounted) {
      setState(() {
        _openTasksList = listResult;
      });
    }
  }

  @override
  void onSlotFloorSummaryExpanded(Widget listResult) {
    if (this.mounted) {
      setState(() {
        _slotFloorList = listResult;
      });
    }
  }

  @override
  void onTeamAvailabilityExpanded(Widget listResult) {
    if (this.mounted) {
      setState(() {
        _teamAvailabilityList = listResult;
      });
    }
  }
}
