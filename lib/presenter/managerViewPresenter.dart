import 'package:flutter/material.dart';
import 'package:techviz/components/dataEntry/dataEntry.dart';
import 'package:techviz/components/dataEntry/dataEntryCell.dart';
import 'package:techviz/components/dataEntry/dataEntryColumn.dart';
import 'package:techviz/components/dataEntry/dataEntryGroup.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/session.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/viewmodel/managerViewUserStatus.dart';

abstract class IManagerViewPresenter {
  void onOpenTasksLoaded(List<DataEntryGroup> list);
  void onTeamAvailabilityLoaded(List<DataEntryGroup> list);
  void onSlotFloorSummaryLoaded(List<DataEntryGroup> list);
  void onUserStatusLoaded(List<ManagerViewUserStatus> list);

  void onTeamAvailabilityError(dynamic error);
  void onSlotFloorError(dynamic error);
  void onOpenTasksError(dynamic error);
}

class ManagerViewPresenter{
  IManagerViewPresenter _view;

  ManagerViewPresenter(this._view){
    assert(_view != null);
  }

  void loadOpenTasks(){

    void handleOpenTasksList(dynamic openTasksList) async {
      List<TaskStatus> listStatuses = await Repository().taskStatusRepository.getAll();
      List<TaskType> listTypes = await Repository().taskTypeRepository.getAll();

      Function timeElapsedParsed = (String elapsedTimeInSeconds){
        int elapsedTime = int.parse(elapsedTimeInSeconds);
        int hours = (elapsedTime/60).floor();
        int mins = (elapsedTime%60).ceil();

        return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
      };

      DataEntry mapToDataEntry(Map<String, dynamic> mapEntry){

        List<DataEntryCell> columns = <DataEntryCell>[];
        Iterable<TaskType> listTypeWhere = listTypes.where((TaskType tt) => tt.taskTypeId == int.parse(mapEntry['TaskTypeID'].toString()));
        Iterable<TaskStatus> listStatusesWhere = listStatuses.where((TaskStatus ts) => ts.id == int.parse(mapEntry['TaskStatusID'].toString()));

        columns.add(DataEntryCell('Location', mapEntry['Location']));
        columns.add(DataEntryCell('Type', listTypeWhere!=null && listTypeWhere.isNotEmpty ? listTypeWhere.first : mapEntry['TaskTypeID'].toString()));
        columns.add(DataEntryCell('Status', listStatusesWhere!=null && listStatusesWhere.isNotEmpty ? listStatusesWhere.first : mapEntry['TaskStatusID'].toString()));
        columns.add(DataEntryCell('User', mapEntry['UserID']));
        columns.add(DataEntryCell('Time Taken', timeElapsedParsed(mapEntry['ElapsedTime'].toString())));

        return DataEntry(mapEntry['_ID'].toString(), columns, onSwipeRightActionConditional: (){
          String userID = mapEntry['UserID'].toString();
          return userID == null || userID != Session().user.userID.toString();
        });
      }

      DataEntry mapToDataEntryForUnassigned(Map<String, dynamic> mapEntry){

        List<DataEntryCell> columns = <DataEntryCell>[];
        Iterable<TaskType> listTypeWhere = listTypes.where((TaskType tt) => tt.taskTypeId == int.parse(mapEntry['TaskTypeID'].toString()));
        Iterable<TaskStatus> listStatusesWhere = listStatuses.where((TaskStatus ts) => ts.id == int.parse(mapEntry['TaskStatusID'].toString()));

        columns.add(DataEntryCell('Location', mapEntry['Location']));
        columns.add(DataEntryCell('Type', listTypeWhere!=null && listTypeWhere.isNotEmpty ? listTypeWhere.first : mapEntry['TaskTypeID'].toString()));
        columns.add(DataEntryCell('Status', listStatusesWhere!=null && listStatusesWhere.isNotEmpty ? listStatusesWhere.first : mapEntry['TaskStatusID'].toString()));
        columns.add(DataEntryCell('Time Taken', timeElapsedParsed(mapEntry['ElapsedTime'].toString())));

        return DataEntry(mapEntry['_ID'].toString(), columns, onSwipeRightActionConditional: (){
          String userID = mapEntry['UserID'].toString();
          return userID == null || userID != Session().user.userID.toString();
        });
      }

      List<DataEntryColumn> assignedColumnsDefinition = [
        DataEntryColumn('Location', alignment: DataAlignment.center),
        DataEntryColumn('Type', alignment: DataAlignment.center),
        DataEntryColumn('Status', alignment: DataAlignment.center),
        DataEntryColumn('User', alignment: DataAlignment.center),
        DataEntryColumn('Time Taken', alignment: DataAlignment.center)
      ];

      List<DataEntryColumn> unassignedColumnsDefinition = [
        DataEntryColumn('Location', alignment: DataAlignment.center),
        DataEntryColumn('Type', alignment: DataAlignment.center),
        DataEntryColumn('Status', alignment: DataAlignment.center),
        DataEntryColumn('Time Taken', alignment: DataAlignment.center),
      ];


      List<DataEntryGroup> group = <DataEntryGroup>[];

      //Assigned: UserID is not null AND TaskStatusID is not equal to 7 (reassigned)
      Iterable<Map<String,dynamic>> assignedWhere = openTasksList.where((Map<String,dynamic> map)=> (map['UserID'] != null && map['UserID'].toString().isNotEmpty) && map['TaskStatusID'] != '7');
      List<DataEntry> assignedList = assignedWhere != null ? assignedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): <DataEntry>[];
      group.add(DataEntryGroup('Assigned', assignedList, assignedColumnsDefinition));


      //Unassigned: UserID is null OR TaskStatusID = 7 (reassigned)
      Iterable<Map<String,dynamic>> unassignedWhere = openTasksList.where((Map<String,dynamic> map)=> (map['UserID'] == null || map['UserID'].toString().isEmpty) || map['TaskStatusID'] == '7');
      List<DataEntry> unassignedList = unassignedWhere != null ? unassignedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntryForUnassigned(d)).toList(): <DataEntry>[];
      group.add(DataEntryGroup('Unassigned', unassignedList, unassignedColumnsDefinition));


      //Overdue: TaskUrgencyID is 3 (overdue)
      Iterable<Map<String,dynamic>> overdueWhere = openTasksList.where((Map<String,dynamic> map)=> map['TaskUrgencyID'] == '3');
      List<DataEntry> overdueList = overdueWhere != null ? overdueWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): <DataEntry>[];
      group.add(DataEntryGroup('Overdue', overdueList, assignedColumnsDefinition, highlightedDecoration: (){ return overdueList.isNotEmpty ? Color(0xFFFF0000): null; }));


      //Escalated: IsTechTask is 1 AND ParentID is not null (all escalated tasks are for technicians and have a parentID)
      Iterable<Map<String,dynamic>> escalatedWhere = openTasksList.where((Map<String,dynamic> map)=> map['IsTechTask']  == '1' && (map['ParentID'] != null && map['ParentID'].toString().isNotEmpty));
      List<DataEntry> escalatedList = escalatedWhere != null ? escalatedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): <DataEntry>[];
      group.add(DataEntryGroup('Escalated', escalatedList, assignedColumnsDefinition));


      _view.onOpenTasksLoaded(group);

    }

    void handleOpenTasksError(dynamic error){
      _view.onOpenTasksError(error);
    }

    Repository().taskRepository.openTasksSummary().then(handleOpenTasksList).catchError(handleOpenTasksError);
  }

  void loadTeamAvailability(){

    void handleTeamAvailabilityList(List<Map> listMap) {

      DataEntry toAvailableDataEntryParser(Map map){
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Sections', map['SectionCount']));
        columns.add(DataEntryCell('Attendant', map['UserName']));
        columns.add(DataEntryCell('Task Count', map['TaskCount']));
        columns.add(DataEntryCell('StatusID', map['UserStatusID']));
        return DataEntry(map['UserID'], columns);
      }

      DataEntry toOnBreakDataEntryParser(Map map){
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Attendant', map['UserName']));
        columns.add(DataEntryCell('Break', map['UserStatusName']));
        columns.add(DataEntryCell('StatusID', map['UserStatusID']));
        return DataEntry(map['UserID'], columns);
      }

      DataEntry toOtherDataEntryParser(Map map){
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Attendant', map['UserName']));
        columns.add(DataEntryCell('Status', map['UserStatusName']));
        columns.add(DataEntryCell('StatusID', map['UserStatusID']));
        return DataEntry(map['UserID'], columns);
      }

      DataEntry toOffShiftDataEntryParser(Map map){
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Attendant', map['UserName']));
        columns.add(DataEntryCell('StatusID', map['UserStatusID']));
        return DataEntry(map['UserID'], columns);
      }

      List<DataEntryGroup> group = <DataEntryGroup>[];
      List<DataEntry> availableList = listMap.where((Map map)=> ['20','30', '35'].contains(map['UserStatusID'])).map((Map map) => toAvailableDataEntryParser(map)).toList();
      List<DataEntry> onBreakList = listMap.where((Map map)=> ['45','50','55'].contains(map['UserStatusID'])).map((Map map) => toOnBreakDataEntryParser(map)).toList();
      List<DataEntry> otherList = listMap.where((Map map)=> ['70','75','80','90'].contains(map['UserStatusID'])).map((Map map) => toOtherDataEntryParser(map)).toList();
      List<DataEntry> offShift = listMap.where((Map map)=> ['10'].contains(map['UserStatusID'])).map((Map map) => toOffShiftDataEntryParser(map)).toList();

      List<DataEntryColumn> availableColumnsDefinition = [
        DataEntryColumn('Sections', alignment: DataAlignment.center),
        DataEntryColumn('Attendant', alignment: DataAlignment.center),
        DataEntryColumn('Task Count', alignment: DataAlignment.center),
        DataEntryColumn('StatusID', alignment: DataAlignment.center, visible: false)
      ];

      List<DataEntryColumn> onBreakColumnsDefinition = [
        DataEntryColumn('Attendant', alignment: DataAlignment.center),
        DataEntryColumn('Break', alignment: DataAlignment.center),
        DataEntryColumn('StatusID', alignment: DataAlignment.center, visible: false)
      ];

      List<DataEntryColumn> otherColumnsDefinition = [
        DataEntryColumn('Attendant', alignment: DataAlignment.center),
        DataEntryColumn('Status', alignment: DataAlignment.center),
        DataEntryColumn('StatusID', alignment: DataAlignment.center, visible: false)
      ];

      List<DataEntryColumn> offShiftColumnsDefinition = [
        DataEntryColumn('Attendant', alignment: DataAlignment.center),
        DataEntryColumn('StatusID', alignment: DataAlignment.center, visible: false)
      ];


      group.add(DataEntryGroup('Available', sortAlphabeticallyByAttendantName(availableList), availableColumnsDefinition));
      group.add(DataEntryGroup('On Break', sortAlphabeticallyByAttendantName(onBreakList), onBreakColumnsDefinition));
      group.add(DataEntryGroup('Other', sortAlphabeticallyByAttendantName(otherList), otherColumnsDefinition));
      group.add(DataEntryGroup('Off Shift', sortAlphabeticallyByAttendantName(offShift), offShiftColumnsDefinition));

      _view.onTeamAvailabilityLoaded(group);
    }

    void handleTeamAvailabilityError(dynamic error){
      _view.onTeamAvailabilityError(error);
    }

    Repository().userRepository.teamAvailabilitySummary().then(handleTeamAvailabilityList).catchError(handleTeamAvailabilityError);
  }

  List<DataEntry> sortAlphabeticallyByAttendantName(List<DataEntry> coll){
    int compateTo(DataEntry a, DataEntry b){
      DataEntryCell userNameA = a.cell.where((DataEntryCell cell) => cell.columnName == 'Attendant').first;
      DataEntryCell userNameB = b.cell.where((DataEntryCell cell) => cell.columnName == 'Attendant').first;
      return userNameA.value.toString().compareTo(userNameB.value.toString());
    }

    coll.sort((DataEntry a, DataEntry b) => compateTo(a,b));
    return coll;
  }


  void loadSlotFloorSummary(){

    void handleSlotFloorList(List<SlotMachine> slotMachineList) async {

      bool allowToReserve(dynamic statusID){
        return statusID == '3';
      }

      bool allowToCancelReservation(dynamic statusID){
        return statusID == '1';
      }

      //ONLINE MACHINES: CAN BE BOTH RESERVED OR CANCELED
      DataEntry slotMachineToDataEntryForActiveGames(SlotMachine slotMachine){
        List<DataEntryCell> columns = <DataEntryCell>[];

        columns.add(DataEntryCell('Location/StandID', slotMachine.standID));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString()));
        columns.add(DataEntryCell('Status', slotMachine.machineStatusDescription));
        return DataEntry(slotMachine.standID, columns, onSwipeRightActionConditional: (){
          return allowToReserve(slotMachine.machineStatusID);
        }, onSwipeLeftActionConditional: (){
          return allowToCancelReservation(slotMachine.machineStatusID);
        });
      }

      //MACHINES IN USE: CAN NOT BE RESERVED OR CANCELED
      DataEntry slotMachineToDataEntryForHeadCount(SlotMachine slotMachine){
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Location/StandID', slotMachine.standID));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString()));
        columns.add(DataEntryCell('PlayerID', slotMachine.playerID));
        return DataEntry(slotMachine.standID, columns, onSwipeLeftActionConditional: (){return false;}, onSwipeRightActionConditional: (){return false;});
      }

      //RESERVED MACHINES: CAN ONLY BE CANCELED; CANOT BE RESERVED
      DataEntry slotMachineToDataEntryForReserved(SlotMachine slotMachine){
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Location/StandID', slotMachine.standID));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString()));
        columns.add(DataEntryCell('PlayerID', slotMachine.playerID));
        columns.add(DataEntryCell('Duration', slotMachine.reservationTime));
        return DataEntry(slotMachine.standID, columns, onSwipeLeftActionConditional: (){
          return allowToCancelReservation(slotMachine.machineStatusID);
        }, onSwipeRightActionConditional: (){return false;});
      }

      //OUT OF SERVICE MACHINES, CAN NOT BE RESERVED OR CANCELED
      DataEntry slotMachineToDataEntryForOutOfService(SlotMachine slotMachine){
        List<DataEntryCell> columns = <DataEntryCell>[];

        columns.add(DataEntryCell('Location/StandID', slotMachine.standID));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString()));
        columns.add(DataEntryCell('Status', slotMachine.machineStatusDescription));
        return DataEntry(slotMachine.standID, columns, onSwipeLeftActionConditional: (){return false;}, onSwipeRightActionConditional: (){return false;});
      }

      Iterable<SlotMachine> activeGamesWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID != '0');
      List<DataEntry> activeGamesList = activeGamesWhere != null ? activeGamesWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForActiveGames(sm)).toList(): <DataEntry>[];

      Iterable<SlotMachine> headCountWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID == '2');
      List<DataEntry> headCountList = headCountWhere != null ? headCountWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForHeadCount(sm)).toList(): <DataEntry>[];

      Iterable<SlotMachine> reservedWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID == '1');
      List<DataEntry> reservedList = reservedWhere != null ? reservedWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForReserved(sm)).toList(): <DataEntry>[];

      Iterable<SlotMachine> outOfServiceWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID == '0');
      List<DataEntry> outOfServiceList = outOfServiceWhere != null ? outOfServiceWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForOutOfService(sm)).toList(): <DataEntry>[];


      List<DataEntryColumn> activeGamesColumnsDefinition = [
        DataEntryColumn('Location/StandID', alignment: DataAlignment.center),
        DataEntryColumn('Game/Theme', alignment: DataAlignment.center, flex: 3),
        DataEntryColumn('Denom', alignment: DataAlignment.center),
        DataEntryColumn('Status', alignment: DataAlignment.center)
      ];

      List<DataEntryColumn> headCountColumnsDefinition = [
        DataEntryColumn('Location/StandID', alignment: DataAlignment.center),
        DataEntryColumn('Game/Theme', alignment: DataAlignment.center, flex: 3),
        DataEntryColumn('Denom', alignment: DataAlignment.center),
        DataEntryColumn('PlayerID', alignment: DataAlignment.center)
      ];

      List<DataEntryColumn> reservedColumnsDefinition = [
        DataEntryColumn('Location/StandID', alignment: DataAlignment.center),
        DataEntryColumn('Game/Theme', alignment: DataAlignment.center, flex: 2),
        DataEntryColumn('Denom', alignment: DataAlignment.center),
        DataEntryColumn('PlayerID', alignment: DataAlignment.center),
        DataEntryColumn('Duration', alignment: DataAlignment.center)
      ];

      List<DataEntryColumn> outOfServiceColumnsDefinition = [
        DataEntryColumn('Location/StandID', alignment: DataAlignment.center),
        DataEntryColumn('Game/Theme', alignment: DataAlignment.center, flex: 3),
        DataEntryColumn('Denom', alignment: DataAlignment.center),
        DataEntryColumn('Status', alignment: DataAlignment.center)
      ];

      List<DataEntryGroup> group = <DataEntryGroup>[];
      group.add(DataEntryGroup('Active Games', activeGamesList, activeGamesColumnsDefinition));
      group.add(DataEntryGroup('Head Count', headCountList, headCountColumnsDefinition));
      group.add(DataEntryGroup('Reserved', reservedList, reservedColumnsDefinition));
      group.add(DataEntryGroup('Out of Service', outOfServiceList, outOfServiceColumnsDefinition, highlightedDecoration: (){ return outOfServiceList.isNotEmpty ? Color(0xFFFF0000): null; }));

      _view.onSlotFloorSummaryLoaded(group);
    }

    void handleSlotFloorError(dynamic error){
      _view.onSlotFloorError(error);
    }

    Repository().slotFloorRepository.slotFloorSummary().then(handleSlotFloorList).catchError(handleSlotFloorError);
  }

  void loadUserStatusList(String currentUserStatusID){
    Repository().userStatusRepository.getStatuses().then((List<UserStatus> list){
      List<ManagerViewUserStatus> output = list.map((UserStatus userStatus) => ManagerViewUserStatus(
        userStatus.id,
        userStatus.description,
        userStatus.id.toString() == currentUserStatusID
      )).toList();

      _view.onUserStatusLoaded(output);
    });
  }

  Future reassign(String taskID, String userID){
    TaskRepository repo = Repository().taskRepository;
    return repo.reassign(taskID, userID);
  }
}