import 'package:techviz/model/summaryEntry.dart';

abstract class IManagerViewPresenter {
  void onOpenTasksLoaded(List<SummaryEntry> summaryList);
  void onTeamAvailabilityLoaded(List<SummaryEntry> summaryList);
  void onSlotFloorSummaryLoaded(List<SummaryEntry> summaryList);

  void onLoadError(dynamic error);
}

class ManagerViewPresenter{
  IManagerViewPresenter _view;

  ManagerViewPresenter(this._view){
    assert(_view != null);
  }

  void loadOpenTasks(){
    Future.delayed(Duration(seconds: 1), (){

      List<SummaryEntry> list = List<SummaryEntry>();

      for(int i =0; i<99; i++){

        Map<String,dynamic> mapEntry = Map<String,dynamic>();
        mapEntry['Location'] = i.toString()+i.toString()+i.toString();
        mapEntry['Type'] = '1';
        mapEntry['Status'] = i<20? 'Assigned' : ((i<40? 'UnAssigned' : i<60? 'Overdue' : 'Escalated'));
        mapEntry['User'] = 'irina';
        mapEntry['TimeTaken'] = i.toString();

        list.add(SummaryEntry(mapEntry));
      }
      _view.onOpenTasksLoaded(list);

    });
  }

  void loadTeamAvailability(){
    Future.delayed(Duration(milliseconds: 500), (){
      List<SummaryEntry> list = List<SummaryEntry>();

      for(int i =0; i<99; i++){

        Map<String,dynamic> mapEntry = Map<String,dynamic>();
        mapEntry['Attendant'] = i.toString()+i.toString()+i.toString();
        mapEntry['Status'] = i<10? 'Available' : ((i<80? 'On Break' : i<85? 'Other' : 'Off Shift'));

        list.add(SummaryEntry(mapEntry));
      }
      _view.onTeamAvailabilityLoaded(list);

    });
  }

  void loadSlotFloorSummary(){
    Future.delayed(Duration(seconds: 2), (){
      List<SummaryEntry> list = List<SummaryEntry>();

      for(int i =0; i<99; i++){

        Map<String,dynamic> mapEntry = Map<String,dynamic>();
        mapEntry['Location/StandID'] = i.toString()+i.toString()+i.toString();
        mapEntry['Game/Theme'] = '1';
        mapEntry['Status'] = i<80? 'Active Games' : ((i<85? 'Head Count' : i<90? 'Reserved' : 'Out of Service'));
        mapEntry['Denom'] = 0.01;

        list.add(SummaryEntry(mapEntry));
      }
      _view.onSlotFloorSummaryLoaded(list);

    });
  }
}