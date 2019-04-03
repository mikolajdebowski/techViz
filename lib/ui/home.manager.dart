
import 'package:flutter/material.dart';
import 'package:techviz/components/vizSummaryHeader.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/openTasksPresenter.dart';
import 'package:techviz/ui/home.dart';

class HomeManager extends StatefulWidget {
  HomeManager(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeManagerState();
}

class HomeManagerState extends State<HomeManager> implements TechVizHome, IOpenTasksPresenter {

  VizSummaryHeader _openTasks;
  VizSummaryHeader _teamAvailability;
  VizSummaryHeader _slotFloor;

  OpenTasksPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _presenter = OpenTasksPresenter(this);
    _presenter.loadOpenTasks();

  }


  @override
  Widget build(BuildContext context) {

    Widget openTasksWidget = _openTasks;
    if(openTasksWidget==null){
      openTasksWidget = CircularProgressIndicator();
    }

    Widget teamAvailabilityWidget = _teamAvailability;
    if(teamAvailabilityWidget==null){
      teamAvailabilityWidget = CircularProgressIndicator();
    }

    Widget slotFloorWidget = _slotFloor;
    if(slotFloorWidget==null){
      slotFloorWidget = CircularProgressIndicator();
    }

    BoxDecoration boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Color(0xFFFFFFFF)),
        gradient: LinearGradient(colors: [Color(0xFF81919D), Color(0xFFAAB7BD)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated));


    Column column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: (Container(decoration: boxDecoration, child: Center(child: openTasksWidget)))),
        SizedBox(height: 5),
        Expanded(child: (Container(decoration: boxDecoration, child: Center(child: teamAvailabilityWidget)))),
        SizedBox(height: 5),
        Expanded(child: (Container(decoration: boxDecoration, child: Center(child: slotFloorWidget)))),
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
    setState(() {
      _openTasks = summaryHeader;
      _teamAvailability = summaryHeader;
      _slotFloor = summaryHeader;
    });
  }

}