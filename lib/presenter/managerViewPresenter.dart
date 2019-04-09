import 'package:flutter/material.dart';
import 'package:techviz/components/vizSummaryHeader.dart';

abstract class IManagerViewPresenter {
  void onOpenTasksLoaded(VizSummaryHeader summaryHeader);
  void onTeamAvailabilityLoaded(VizSummaryHeader summaryHeader);
  void onSlotFloorSummaryLoaded(VizSummaryHeader summaryHeader);

  void onOpenTasksExpanded(String selectedTag, Widget listResult);
  void onTeamAvailabilityExpanded(String selectedTag, Widget listResult);
  void onSlotFloorSummaryExpanded(String selectedTag, Widget listResult);

  void onLoadError(dynamic error);
}

class ManagerViewPresenter{
  IManagerViewPresenter _view;

  ManagerViewPresenter(this._view){
    assert(_view != null);
  }

  void loadOpenTasks(){
    Future.delayed(Duration(seconds: 1), (){
      List<VizSummaryHeaderEntry> entries = [
        VizSummaryHeaderEntry('Assigned', 12, onEntryTapCallback: (){
          _view.onOpenTasksExpanded('Assigned', Text('Assigned'));
        }),
        VizSummaryHeaderEntry('Un-Assigned', 4, onEntryTapCallback: (){
          _view.onOpenTasksExpanded('Un-Assigned', Text('Un-Assigned'));
        }),
        VizSummaryHeaderEntry('Overdue', 1, onEntryTapCallback: (){
          _view.onOpenTasksExpanded('Overdue', Text('Overdue'));
        }),
        VizSummaryHeaderEntry('Escalated', 2, onEntryTapCallback: (){
          _view.onOpenTasksExpanded('Escalated', Text('Escalated'));
        })
      ];

      VizSummaryHeader header = VizSummaryHeader(headerTitle: 'Tasks', entries: entries);

      _view.onOpenTasksLoaded(header);

    });
  }

  void loadTeamAvailability(){
    Future.delayed(Duration(milliseconds: 500), (){
      List<VizSummaryHeaderEntry> entries = [
        VizSummaryHeaderEntry('On the Floor', 12),
        VizSummaryHeaderEntry('On Break', 4),
        VizSummaryHeaderEntry('Other', 1),
        VizSummaryHeaderEntry('Off Shift', 23)
      ];

      VizSummaryHeader header = VizSummaryHeader(headerTitle: 'Team Availability', entries: entries);

      _view.onTeamAvailabilityLoaded(header);

    });
  }

  void loadSlotFloorSummary(){
    Future.delayed(Duration(seconds: 2), (){
      List<VizSummaryHeaderEntry> entries = [
        VizSummaryHeaderEntry('Active Games', 1347),
        VizSummaryHeaderEntry('Head Count', 223),
        VizSummaryHeaderEntry('Reserved', 1),
        VizSummaryHeaderEntry('Out of Service', 2)
      ];

      VizSummaryHeader header = VizSummaryHeader(headerTitle:'Slot Floor', entries: entries);

      _view.onSlotFloorSummaryLoaded(header);

    });
  }
}