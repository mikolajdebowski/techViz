import 'package:flutter/material.dart';
import 'package:techviz/components/vizSummary.dart';
import 'package:techviz/model/summaryEntry.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/managerViewPresenter.dart';
import 'package:techviz/ui/home.dart';

class HomeManager extends StatefulWidget {
  HomeManager(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeManagerState();
}

class HomeManagerState extends State<HomeManager> implements TechVizHome, IManagerViewPresenter {
  ManagerViewPresenter _presenter;

  List<SummaryEntry> _openTasksList;
  List<SummaryEntry> _teamAvailabilityList;
  List<SummaryEntry> _slotFloorList;

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
            VizSummary('Open Tasks', _openTasksList, ['Status']),
            VizSummary('Team Availability', _teamAvailabilityList, ['Status']),
            VizSummary('Slot floor', _slotFloorList, ['Status'])
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
  void onOpenTasksLoaded(List<SummaryEntry> summaryList) {
    if (this.mounted) {
      setState(() {
        _openTasksList = summaryList;
      });
    }
  }

  @override
  void onSlotFloorSummaryLoaded(List<SummaryEntry> summaryList) {
    if (this.mounted) {
      setState(() {
        _slotFloorList = summaryList;
      });
    }
  }

  @override
  void onTeamAvailabilityLoaded(List<SummaryEntry> summaryList) {
    if (this.mounted) {
      setState(() {
        _teamAvailabilityList = summaryList;
      });
    }
  }
}
