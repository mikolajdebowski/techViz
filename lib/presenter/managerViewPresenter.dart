import 'package:techviz/model/dataEntry.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskRepository.dart';

abstract class IManagerViewPresenter {
  void onOpenTasksLoaded(List<DataEntry> summaryList);
  void onTeamAvailabilityLoaded(List<DataEntry> summaryList);
  void onSlotFloorSummaryLoaded(List<DataEntry> summaryList);

  void onLoadError(dynamic error);
}

class ManagerViewPresenter{
  IManagerViewPresenter _view;

  ManagerViewPresenter(this._view){
    assert(_view != null);
  }

  void loadOpenTasks(){
    Future.delayed(Duration(seconds: 1), (){

      List<DataEntry> list = List<DataEntry>();

      for(int i =0; i<99; i++){

        Map<String,dynamic> mapEntry = Map<String,dynamic>();
        mapEntry['Location'] = i.toString()+i.toString()+i.toString();
        mapEntry['Type'] = '1';
        mapEntry['Status'] = i<20? 'Assigned' : ((i<40? 'Unassigned' : i<60? 'Overdue' : 'Escalated'));
        mapEntry['User'] = 'irina';
        mapEntry['TimeTaken'] = i.toString();

        list.add(DataEntry(mapEntry));
      }
      _view.onOpenTasksLoaded(list);

    });
  }

  void loadTeamAvailability(){
    Future.delayed(Duration(milliseconds: 500), (){
      List<DataEntry> list = List<DataEntry>();

      for(int i =0; i<99; i++){

        Map<String,dynamic> mapEntry = Map<String,dynamic>();
        mapEntry['Attendant'] = i.toString()+i.toString()+i.toString();
        mapEntry['Status'] = i<10? 'Available' : ((i<80? 'On Break' : i<85? 'Other' : 'Off Shift'));

        list.add(DataEntry(mapEntry));
      }
      _view.onTeamAvailabilityLoaded(list);

    });
  }

  void loadSlotFloorSummary(){
    Future.delayed(Duration(seconds: 2), (){
      List<DataEntry> list = List<DataEntry>();

      for(int i =0; i<99; i++){

        Map<String,dynamic> mapEntry = Map<String,dynamic>();
        mapEntry['Location/StandID'] = i.toString()+i.toString()+i.toString();
        mapEntry['Game/Theme'] = '1';
        mapEntry['Status'] = i<80? 'Active Games' : ((i<85? 'Head Count' : i<90? 'Reserved' : 'Out of Service'));
        mapEntry['Denom'] = 0.01;

        list.add(DataEntry(mapEntry));
      }
      _view.onSlotFloorSummaryLoaded(list);

    });
  }

  Future reassign(String taskID, String userID){
    TaskRepository repo = Repository().taskRepository;
    return repo.reassign(taskID, userID);
  }
}