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

        //ASSIGNED todo: confirm if TaskStatusID equals to 1 means assigned
        Iterable<Map<String,dynamic>> assignedWhere = result.where((Map<String,dynamic> map)=> map['TaskStatusID'] == '1');
        List<DataEntry> assignedList = assignedWhere != null ? assignedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): List<DataEntry>();

        //UNASSIGNED todo: confirm if TaskStatusID equals to 0 means unassigned
        Iterable<Map<String,dynamic>> unassignedWhere = result.where((Map<String,dynamic> map)=> map['TaskStatusID'] == '0');
        List<DataEntry> unassignedList = unassignedWhere != null ? unassignedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): List<DataEntry>();

        //OVERDUE? todo: find out when a task is overdue
        Iterable<Map<String,dynamic>> overdueWhere = result.where((Map<String,dynamic> map)=> int.parse(map['ElapsedTime'] as String) > 1000);
        List<DataEntry> overdueList = overdueWhere != null ? overdueWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): List<DataEntry>();

        //ESCALATED? todo: find out when a task is escalated
        Iterable<Map<String,dynamic>> escalatedWhere = result.where((Map<String,dynamic> map)=> map['TaskStatusID']  == '5');
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