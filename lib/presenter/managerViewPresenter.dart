import 'package:flutter/material.dart';
import 'package:techviz/model/dataEntry.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/session.dart';
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
      Repository().taskRepository.openTasksSummary().then((dynamic result) async {

        List<TaskStatus> listStatuses = await Repository().taskStatusRepository.getAll();
        List<TaskType> listTypes = await Repository().taskTypeRepository.getAll();

        Function timeElapsedParsed = (String elapsedTimeInSeconds){
          int elapsedTime = int.parse(elapsedTimeInSeconds);
          int hours = (elapsedTime/60).floor();
          int mins = (elapsedTime%60).ceil();

          return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
        };

        DataEntry mapToDataEntry(Map<String, dynamic> mapEntry){

          List<DataEntryCell> columns = List<DataEntryCell>();
          Iterable<TaskType> listTypeWhere = listTypes.where((TaskType tt) => tt.taskTypeId == int.parse(mapEntry['TaskTypeID'].toString()));
          Iterable<TaskStatus> listStatusesWhere = listStatuses.where((TaskStatus ts) => ts.id == int.parse(mapEntry['TaskStatusID'].toString()));

          columns.add(DataEntryCell('Location', mapEntry['Location'], alignment: DataAlignment.center));
          columns.add(DataEntryCell('Type', listTypeWhere!=null && listTypeWhere.length>0 ? listTypeWhere.first : mapEntry['TaskTypeID'].toString()));
          columns.add(DataEntryCell('Status', listStatusesWhere!=null && listStatusesWhere.length>0 ? listStatusesWhere.first : mapEntry['TaskStatusID'].toString(), alignment: DataAlignment.center));
          columns.add(DataEntryCell('User', mapEntry['UserID'], alignment: DataAlignment.center));
          columns.add(DataEntryCell('Time Taken', timeElapsedParsed(mapEntry['ElapsedTime'].toString()), alignment: DataAlignment.center));

          return DataEntry(mapEntry['_ID'].toString(), columns, onSwipeRightActionConditional: (){
            String userID = mapEntry['UserID'].toString();
            return userID == null || userID != Session().user.userID.toString();
          });
        }

        DataEntry mapToDataEntryForUnassigned(Map<String, dynamic> mapEntry){

          List<DataEntryCell> columns = List<DataEntryCell>();
          Iterable<TaskType> listTypeWhere = listTypes.where((TaskType tt) => tt.taskTypeId == int.parse(mapEntry['TaskTypeID'].toString()));
          Iterable<TaskStatus> listStatusesWhere = listStatuses.where((TaskStatus ts) => ts.id == int.parse(mapEntry['TaskStatusID'].toString()));

          columns.add(DataEntryCell('Location', mapEntry['Location'], alignment: DataAlignment.center));
          columns.add(DataEntryCell('Type', listTypeWhere!=null && listTypeWhere.length>0 ? listTypeWhere.first : mapEntry['TaskTypeID'].toString()));
          columns.add(DataEntryCell('Status', listStatusesWhere!=null && listStatusesWhere.length>0 ? listStatusesWhere.first : mapEntry['TaskStatusID'].toString(), alignment: DataAlignment.center));
          columns.add(DataEntryCell('Time Taken', timeElapsedParsed(mapEntry['ElapsedTime'].toString()), alignment: DataAlignment.center));

          return DataEntry(mapEntry['_ID'].toString(), columns, onSwipeRightActionConditional: (){
            String userID = mapEntry['UserID'].toString();
            return userID == null || userID != Session().user.userID.toString();
          });
        }

        //from ACT-1344
        //Assigned: UserID is not null AND TaskStatusID is not equal to 7 (reassigned)
        Iterable<Map<String,dynamic>> assignedWhere = result.where((Map<String,dynamic> map)=> (map['UserID'] != null && map['UserID'].toString().length>0) && map['TaskStatusID'] != '7');
        List<DataEntry> assignedList = assignedWhere != null ? assignedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): List<DataEntry>();

        //Unassigned: UserID is null OR TaskStatusID = 7 (reassigned)
        Iterable<Map<String,dynamic>> unassignedWhere = result.where((Map<String,dynamic> map)=> (map['UserID'] == null || map['UserID'].toString().length==0) || map['TaskStatusID'] == '7');
        List<DataEntry> unassignedList = unassignedWhere != null ? unassignedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntryForUnassigned(d)).toList(): List<DataEntry>();

        //Overdue: TaskUrgencyID is 3 (overdue)
        Iterable<Map<String,dynamic>> overdueWhere = result.where((Map<String,dynamic> map)=> map['TaskUrgencyID'] == '3');
        List<DataEntry> overdueList = overdueWhere != null ? overdueWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): List<DataEntry>();

        //Escalated: IsTechTask is 1 AND ParentID is not null (all escalated tasks are for technicians and have a parentID)
        Iterable<Map<String,dynamic>> escalatedWhere = result.where((Map<String,dynamic> map)=> map['IsTechTask']  == '1' && (map['ParentID'] != null && map['ParentID'].toString().length>0));
        List<DataEntry> escalatedList = escalatedWhere != null ? escalatedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): List<DataEntry>();

        List<DataEntryGroup> group = List<DataEntryGroup>();
        group.add(DataEntryGroup('Assigned', assignedList));
        group.add(DataEntryGroup('Unassigned', unassignedList));
        group.add(DataEntryGroup('Overdue', overdueList, highlightedDecoration: (){ return overdueList.length > 0 ? Color(0xFFFF0000): null; }));
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
    Repository().slotFloorRepository.slotFloorSummary().then((dynamic result) async {

      List<SlotMachine> slotMachineList = result as List<SlotMachine>;

      bool allowToReserve(dynamic statusID){
        return statusID != '1';
      }

      bool allowToCancelReservation(dynamic statusID){
        return statusID == '1';
      }

      //ONLINE MACHINES: CAN BE BOTH RESERVED OR CANCELED
      DataEntry slotMachineToDataEntryForActiveGames(SlotMachine slotMachine){
        List<DataEntryCell> columns = List<DataEntryCell>();

        columns.add(DataEntryCell('Location/StandID', slotMachine.standID, alignment: DataAlignment.center));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString(), alignment: DataAlignment.center));
        columns.add(DataEntryCell('Status', slotMachine.machineStatusDescription, alignment: DataAlignment.center));
        return DataEntry(slotMachine.standID, columns, onSwipeRightActionConditional: (){
          return allowToReserve(slotMachine.machineStatusID);
        }, onSwipeLeftActionConditional: (){
          return allowToCancelReservation(slotMachine.machineStatusID);
        });
      }

      //MACHINES IN USE: CAN NOT BE RESERVED OR CANCELED
      DataEntry slotMachineToDataEntryForHeadCount(SlotMachine slotMachine){
        List<DataEntryCell> columns = List<DataEntryCell>();
        columns.add(DataEntryCell('Location/StandID', slotMachine.standID, alignment: DataAlignment.center));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString(), alignment: DataAlignment.center));
        columns.add(DataEntryCell('PlayerID', slotMachine.playerID, alignment: DataAlignment.center));
        return DataEntry(slotMachine.standID, columns, onSwipeLeftActionConditional: (){return false;}, onSwipeRightActionConditional: (){return false;});
      }

      //RESERVED MACHINES: CAN ONLY BE CANCELED; CANOT BE RESERVED
      DataEntry slotMachineToDataEntryForReserved(SlotMachine slotMachine){
        List<DataEntryCell> columns = List<DataEntryCell>();
        columns.add(DataEntryCell('Location/StandID', slotMachine.standID, alignment: DataAlignment.center));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString(), alignment: DataAlignment.center));
        columns.add(DataEntryCell('PlayerID', slotMachine.playerID, alignment: DataAlignment.center));
        columns.add(DataEntryCell('Duration', slotMachine.reservationTime, alignment: DataAlignment.center));
        return DataEntry(slotMachine.standID, columns, onSwipeLeftActionConditional: (){
          return allowToCancelReservation(slotMachine.machineStatusID);
        }, onSwipeRightActionConditional: (){return false;});
      }

      //OUT OF SERVICE MACHINES, CAN NOT BE RESERVED OR CANCELED
      DataEntry slotMachineToDataEntryForOutOfService(SlotMachine slotMachine){
        List<DataEntryCell> columns = List<DataEntryCell>();

        columns.add(DataEntryCell('Location/StandID', slotMachine.standID, alignment: DataAlignment.center));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString(), alignment: DataAlignment.center));
        columns.add(DataEntryCell('Status', slotMachine.machineStatusDescription, alignment: DataAlignment.center));
        return DataEntry(slotMachine.standID, columns, onSwipeLeftActionConditional: (){return false;}, onSwipeRightActionConditional: (){return false;});
      }

      Iterable<SlotMachine> activeGamesWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID != '0');
      List<DataEntry> activeGamesList = activeGamesWhere != null ? activeGamesWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForActiveGames(sm)).toList(): List<DataEntry>();

      Iterable<SlotMachine> headCountWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID == '2');
      List<DataEntry> headCountList = headCountWhere != null ? headCountWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForHeadCount(sm)).toList(): List<DataEntry>();

      Iterable<SlotMachine> reservedWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID == '1');
      List<DataEntry> reservedList = reservedWhere != null ? reservedWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForReserved(sm)).toList(): List<DataEntry>();

      Iterable<SlotMachine> outOfServiceWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID == '0');
      List<DataEntry> outOfServiceList = outOfServiceWhere != null ? outOfServiceWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForOutOfService(sm)).toList(): List<DataEntry>();

      List<DataEntryGroup> group = List<DataEntryGroup>();
      group.add(DataEntryGroup('Active Games', activeGamesList));
      group.add(DataEntryGroup('Head Count', headCountList));
      group.add(DataEntryGroup('Reserved', reservedList));
      group.add(DataEntryGroup('Out of Service', outOfServiceList, highlightedDecoration: (){ return outOfServiceList.length > 0 ? Color(0xFFFF0000): null; }));

      _view.onSlotFloorSummaryLoaded(group);
    });
  }

  Future reassign(String taskID, String userID){
    TaskRepository repo = Repository().taskRepository;
    return repo.reassign(taskID, userID);
  }
}