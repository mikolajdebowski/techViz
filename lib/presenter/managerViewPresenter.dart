import 'package:techviz/model/dataEntry.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskRepository.dart';

abstract class IManagerViewPresenter {
  void onOpenTasksLoaded(List<DataEntryGroup> list);
  void onTeamAvailabilityLoaded(List<DataEntryGroup> list);
  void onSlotFloorSummaryLoaded(List<DataEntryGroup> list);

  void onLoadError(dynamic error);
}

class ManagerViewPresenter{
  IManagerViewPresenter _view;

  ManagerViewPresenter(this._view){
    assert(_view != null);
  }

  void loadOpenTasks(){
      Repository().taskRepository.openTasks().then((dynamic result){

        DataEntry mapToDataEntry(Map<String, dynamic> mapEntry){

          Map<String,dynamic> columns = Map<String,dynamic>();
          columns['Location'] = mapEntry['Location'];
          columns['Type'] = mapEntry['TaskTypeID']; //convert to business readable string
          columns['Status'] = mapEntry['TaskStatusID']; //convert to business readable string
          columns['User'] = mapEntry['UserID'];
          columns['Time Taken'] = mapEntry['ElapsedTime'];

          return DataEntry(mapEntry['_ID'].toString(), columns);
        }

        //from ACT-1344
        //Assigned: UserID is not null AND TaskStatusID is not equal to 7 (reassigned)
        Iterable<Map<String,dynamic>> assignedWhere = result.where((Map<String,dynamic> map)=> (map['UserID'] != null && map['UserID'].toString().length>0) && map['TaskStatusID'] != '7');
        List<DataEntry> assignedList = assignedWhere != null ? assignedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): List<DataEntry>();


        //Unassigned: UserID is null OR TaskStatusID = 7 (reassigned)
        Iterable<Map<String,dynamic>> unassignedWhere = result.where((Map<String,dynamic> map)=> (map['UserID'] == null || map['UserID'].toString().length==0) || map['TaskStatusID'] == '7');
        List<DataEntry> unassignedList = unassignedWhere != null ? unassignedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): List<DataEntry>();

        //Overdue: TaskUrgencyID is 3 (overdue)
        Iterable<Map<String,dynamic>> overdueWhere = result.where((Map<String,dynamic> map)=> map['TaskUrgencyID'] == '3');
        List<DataEntry> overdueList = overdueWhere != null ? overdueWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): List<DataEntry>();

        //Escalated: IsTechTask is 1 AND ParentID is not null (all escalated tasks are for technicians and have a parentID)
        Iterable<Map<String,dynamic>> escalatedWhere = result.where((Map<String,dynamic> map)=> map['IsTechTask']  == '1' && map['ParentID'] != null);
        List<DataEntry> escalatedList = escalatedWhere != null ? escalatedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): List<DataEntry>();

        List<DataEntryGroup> group = List<DataEntryGroup>();
        group.add(DataEntryGroup('Assigned', assignedList));
        group.add(DataEntryGroup('Unassigned', unassignedList));
        group.add(DataEntryGroup('Overdue', overdueList));
        group.add(DataEntryGroup('Escalated', escalatedList));

        _view.onOpenTasksLoaded(group);
      });
  }

  void loadTeamAvailability(){

    Future.delayed(Duration(milliseconds: 500), (){
      List<DataEntryGroup> group = List<DataEntryGroup>();
      group.add(DataEntryGroup('Available', List<DataEntry>()));
      group.add(DataEntryGroup('On Break', List<DataEntry>()));
      group.add(DataEntryGroup('Other', List<DataEntry>()));
      group.add(DataEntryGroup('Off Shift', List<DataEntry>()));

      _view.onTeamAvailabilityLoaded(group);
    });
  }

  void loadSlotFloorSummary(){
    Future.delayed(Duration(milliseconds: 500), (){
      List<DataEntryGroup> group = List<DataEntryGroup>();
      group.add(DataEntryGroup('Active Games', List<DataEntry>()));
      group.add(DataEntryGroup('Head Count', List<DataEntry>()));
      group.add(DataEntryGroup('Reserved', List<DataEntry>()));
      group.add(DataEntryGroup('Out of Service', List<DataEntry>()));

      _view.onSlotFloorSummaryLoaded(group);
    });
  }

  Future reassign(String taskID, String userID){
    TaskRepository repo = Repository().taskRepository;
    return repo.reassign(taskID, userID);
  }
}