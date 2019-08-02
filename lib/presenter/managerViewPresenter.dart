import 'package:flutter/material.dart';
import 'package:techviz/components/dataEntry/dataEntry.dart';
import 'package:techviz/components/dataEntry/dataEntryCell.dart';
import 'package:techviz/components/dataEntry/dataEntryGroup.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/userStatusRepository.dart';
import 'package:techviz/session.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/ui/profile.dart';
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


      // ACT-1491 - Manager/Supervisor or Tech Manager/Supervisor should not be able to reassign to themselves if they are Off Shift
      DataEntry mapToDataEntry(Map<String, dynamic> mapEntry){

        List<DataEntryCell> columns = <DataEntryCell>[];
        Iterable<TaskType> listTypeWhere = listTypes.where((TaskType tt) => tt.taskTypeId == int.parse(mapEntry['TaskTypeID'].toString()));
        Iterable<TaskStatus> listStatusesWhere = listStatuses.where((TaskStatus ts) => ts.id == int.parse(mapEntry['TaskStatusID'].toString()));

        columns.add(DataEntryCell('Location', mapEntry['Location'], alignment: DataAlignment.center));
        columns.add(DataEntryCell('Type', listTypeWhere!=null && listTypeWhere.isNotEmpty ? listTypeWhere.first : mapEntry['TaskTypeID'].toString()));
        columns.add(DataEntryCell('Status', listStatusesWhere!=null && listStatusesWhere.isNotEmpty ? listStatusesWhere.first : mapEntry['TaskStatusID'].toString(), alignment: DataAlignment.center));
        columns.add(DataEntryCell('User', mapEntry['UserID'], alignment: DataAlignment.center));
        columns.add(DataEntryCell('Time Taken', timeElapsedParsed(mapEntry['ElapsedTime'].toString()), alignment: DataAlignment.center));

        UserStatusRepository userStatusRepo = Repository().userStatusRepository;
        UserStatus currentUserStatus;
        ISession session = Session();
        userStatusRepo.getStatuses().then((List<UserStatus> list) {
          currentUserStatus = list.where((UserStatus status)=> status.id == session.user.userStatusID.toString()).first;
        });
        Role role = Session().role;


        return DataEntry(mapEntry['_ID'].toString(), columns, onSwipeRightActionConditional: (){
          String userID = mapEntry['UserID'].toString();
          bool shouldAllowTakeTask = userID == null || userID != Session().user.userID.toString();

          if(role.isManager || role.isSupervisor || role.isTechManager || role.isTechSupervisor) {
            if (currentUserStatus.description == 'OFF SHIFT') {
              shouldAllowTakeTask = false;
            }
          }

          return shouldAllowTakeTask;
        });
      }







      DataEntry mapToDataEntryForUnassigned(Map<String, dynamic> mapEntry){

        List<DataEntryCell> columns = <DataEntryCell>[];
        Iterable<TaskType> listTypeWhere = listTypes.where((TaskType tt) => tt.taskTypeId == int.parse(mapEntry['TaskTypeID'].toString()));
        Iterable<TaskStatus> listStatusesWhere = listStatuses.where((TaskStatus ts) => ts.id == int.parse(mapEntry['TaskStatusID'].toString()));

        columns.add(DataEntryCell('Location', mapEntry['Location'], alignment: DataAlignment.center));
        columns.add(DataEntryCell('Type', listTypeWhere!=null && listTypeWhere.isNotEmpty ? listTypeWhere.first : mapEntry['TaskTypeID'].toString()));
        columns.add(DataEntryCell('Status', listStatusesWhere!=null && listStatusesWhere.isNotEmpty ? listStatusesWhere.first : mapEntry['TaskStatusID'].toString(), alignment: DataAlignment.center));
        columns.add(DataEntryCell('Time Taken', timeElapsedParsed(mapEntry['ElapsedTime'].toString()), alignment: DataAlignment.center));

        UserStatusRepository userStatusRepo = Repository().userStatusRepository;
        UserStatus currentUserStatus;
        ISession session = Session();
        userStatusRepo.getStatuses().then((List<UserStatus> list) {
          currentUserStatus = list.where((UserStatus status)=> status.id == session.user.userStatusID.toString()).first;
        });
        Role role = Session().role;


        return DataEntry(mapEntry['_ID'].toString(), columns, onSwipeRightActionConditional: (){
          String userID = mapEntry['UserID'].toString();
          bool shouldAllowTakeTask = userID == null || userID != Session().user.userID.toString();

          if(role.isManager || role.isSupervisor || role.isTechManager || role.isTechSupervisor) {
            if (currentUserStatus.description == 'OFF SHIFT') {
              shouldAllowTakeTask = false;
            }
          }

          return shouldAllowTakeTask;
        });
      }







      //from ACT-1344
      //Assigned: UserID is not null AND TaskStatusID is not equal to 7 (reassigned)
      Iterable<Map<String,dynamic>> assignedWhere = openTasksList.where((Map<String,dynamic> map)=> (map['UserID'] != null && map['UserID'].toString().isNotEmpty) && map['TaskStatusID'] != '7');
      List<DataEntry> assignedList = assignedWhere != null ? assignedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): <DataEntry>[];

      //Unassigned: UserID is null OR TaskStatusID = 7 (reassigned)
      Iterable<Map<String,dynamic>> unassignedWhere = openTasksList.where((Map<String,dynamic> map)=> (map['UserID'] == null || map['UserID'].toString().isEmpty) || map['TaskStatusID'] == '7');
      List<DataEntry> unassignedList = unassignedWhere != null ? unassignedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntryForUnassigned(d)).toList(): <DataEntry>[];

      //Overdue: TaskUrgencyID is 3 (overdue)
      Iterable<Map<String,dynamic>> overdueWhere = openTasksList.where((Map<String,dynamic> map)=> map['TaskUrgencyID'] == '3');
      List<DataEntry> overdueList = overdueWhere != null ? overdueWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): <DataEntry>[];

      //Escalated: IsTechTask is 1 AND ParentID is not null (all escalated tasks are for technicians and have a parentID)
      Iterable<Map<String,dynamic>> escalatedWhere = openTasksList.where((Map<String,dynamic> map)=> map['IsTechTask']  == '1' && (map['ParentID'] != null && map['ParentID'].toString().isNotEmpty));
      List<DataEntry> escalatedList = escalatedWhere != null ? escalatedWhere.map<DataEntry>((Map<String,dynamic> d)=> mapToDataEntry(d)).toList(): <DataEntry>[];

      List<DataEntryGroup> group = <DataEntryGroup>[];
      group.add(DataEntryGroup('Assigned', assignedList));
      group.add(DataEntryGroup('Unassigned', unassignedList));
      group.add(DataEntryGroup('Overdue', overdueList, highlightedDecoration: (){ return overdueList.isNotEmpty ? Color(0xFFFF0000): null; }));
      group.add(DataEntryGroup('Escalated', escalatedList));

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
        columns.add(DataEntryCell('Sections', map['SectionCount'], alignment: DataAlignment.center));
        columns.add(DataEntryCell('Attendant', map['UserName'], alignment: DataAlignment.left));
        columns.add(DataEntryCell('Task Count', map['TaskCount'], alignment: DataAlignment.center));
        columns.add(DataEntryCell('StatusID', map['UserStatusID'], visible: false));
        return DataEntry(map['UserID'], columns);
      }

      DataEntry toOnBreakDataEntryParser(Map map){
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Attendant', map['UserName'], alignment: DataAlignment.left));
        columns.add(DataEntryCell('Break', map['UserStatusName'], alignment: DataAlignment.center));
        columns.add(DataEntryCell('StatusID', map['UserStatusID'], visible: false));
        return DataEntry(map['UserID'], columns);
      }

      DataEntry toOtherDataEntryParser(Map map){
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Attendant', map['UserName'], alignment: DataAlignment.left));
        columns.add(DataEntryCell('Status', map['UserStatusName'], alignment: DataAlignment.center));
        columns.add(DataEntryCell('StatusID', map['UserStatusID'], visible: false));
        return DataEntry(map['UserID'], columns);
      }

      DataEntry toOffShiftDataEntryParser(Map map){
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Attendant', map['UserName'], alignment: DataAlignment.left));
        columns.add(DataEntryCell('StatusID', map['UserStatusID'], visible: false));
        return DataEntry(map['UserID'], columns);
      }

      List<DataEntryGroup> group = <DataEntryGroup>[];
      List<DataEntry> availableList = listMap.where((Map map)=> ['20','30', '35'].contains(map['UserStatusID'])).map((Map map) => toAvailableDataEntryParser(map)).toList();
      List<DataEntry> onBreakList = listMap.where((Map map)=> ['45','50','55'].contains(map['UserStatusID'])).map((Map map) => toOnBreakDataEntryParser(map)).toList();
      List<DataEntry> otherList = listMap.where((Map map)=> ['70','75','80','90'].contains(map['UserStatusID'])).map((Map map) => toOtherDataEntryParser(map)).toList();
      List<DataEntry> offShift = listMap.where((Map map)=> ['10'].contains(map['UserStatusID'])).map((Map map) => toOffShiftDataEntryParser(map)).toList();


      group.add(DataEntryGroup('Available', sortAlphabeticallyByAttendantName(availableList)));
      group.add(DataEntryGroup('On Break', sortAlphabeticallyByAttendantName(onBreakList)));
      group.add(DataEntryGroup('Other', sortAlphabeticallyByAttendantName(otherList)));
      group.add(DataEntryGroup('Off Shift', sortAlphabeticallyByAttendantName(offShift)));

      _view.onTeamAvailabilityLoaded(group);
    }

    void handleTeamAvailabilityError(dynamic error){
      _view.onTeamAvailabilityError(error);
    }

    Repository().userRepository.teamAvailabilitySummary().then(handleTeamAvailabilityList).catchError(handleTeamAvailabilityError);
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
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Location/StandID', slotMachine.standID, alignment: DataAlignment.center));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString(), alignment: DataAlignment.center));
        columns.add(DataEntryCell('PlayerID', slotMachine.playerID, alignment: DataAlignment.center));
        return DataEntry(slotMachine.standID, columns, onSwipeRightActionConditional: (){
          return allowToReserve(slotMachine.machineStatusID);
        }, onSwipeLeftActionConditional: (){
          return allowToCancelReservation(slotMachine.machineStatusID);
        });
      }

      //RESERVED MACHINES: CAN ONLY BE CANCELED; CANOT BE RESERVED
      DataEntry slotMachineToDataEntryForReserved(SlotMachine slotMachine){
        List<DataEntryCell> columns = <DataEntryCell>[];
        columns.add(DataEntryCell('Location/StandID', slotMachine.standID, alignment: DataAlignment.center));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString(), alignment: DataAlignment.center));
        columns.add(DataEntryCell('PlayerID', slotMachine.playerID, alignment: DataAlignment.center));
        columns.add(DataEntryCell('Duration', slotMachine.reservationTime, alignment: DataAlignment.center));
        return DataEntry(slotMachine.standID, columns, onSwipeLeftActionConditional: (){
          return allowToCancelReservation(slotMachine.machineStatusID);
        }, onSwipeRightActionConditional: (){
          return false;
        });
      }

      //OUT OF SERVICE MACHINES, CAN NOT BE RESERVED OR CANCELED
      DataEntry slotMachineToDataEntryForOutOfService(SlotMachine slotMachine){
        List<DataEntryCell> columns = <DataEntryCell>[];

        columns.add(DataEntryCell('Location/StandID', slotMachine.standID, alignment: DataAlignment.center));
        columns.add(DataEntryCell('Game/Theme', slotMachine.machineTypeName));
        columns.add(DataEntryCell('Denom', slotMachine.denom.toString(), alignment: DataAlignment.center));
        columns.add(DataEntryCell('Status', slotMachine.machineStatusDescription, alignment: DataAlignment.center));
        return DataEntry(slotMachine.standID, columns, onSwipeLeftActionConditional: (){
          return false;
        }, onSwipeRightActionConditional: (){
          return false;
        });
      }

      Iterable<SlotMachine> activeGamesWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID != '0');
      List<DataEntry> activeGamesList = activeGamesWhere != null ? activeGamesWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForActiveGames(sm)).toList(): <DataEntry>[];

      Iterable<SlotMachine> headCountWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID == '2');
      List<DataEntry> headCountList = headCountWhere != null ? headCountWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForHeadCount(sm)).toList(): <DataEntry>[];

      Iterable<SlotMachine> reservedWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID == '1');
      List<DataEntry> reservedList = reservedWhere != null ? reservedWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForReserved(sm)).toList(): <DataEntry>[];

      Iterable<SlotMachine> outOfServiceWhere = slotMachineList.where((SlotMachine sm)=> sm.machineStatusID == '0');
      List<DataEntry> outOfServiceList = outOfServiceWhere != null ? outOfServiceWhere.map<DataEntry>((SlotMachine sm)=> slotMachineToDataEntryForOutOfService(sm)).toList(): <DataEntry>[];

      List<DataEntryGroup> group = <DataEntryGroup>[];
      group.add(DataEntryGroup('Active Games', activeGamesList));
      group.add(DataEntryGroup('Head Count', headCountList));
      group.add(DataEntryGroup('Reserved', reservedList));
      group.add(DataEntryGroup('Out of Service', outOfServiceList, highlightedDecoration: (){ return outOfServiceList.isNotEmpty ? Color(0xFFFF0000): null; }));

      _view.onSlotFloorSummaryLoaded(group);


    }

    void handleSlotFloorError(dynamic error){
      _view.onSlotFloorError(error);
    }

    Repository().slotFloorRepository.slotFloorSummary().then(handleSlotFloorList).catchError(handleSlotFloorError);
  }

  List<DataEntry> sortAlphabeticallyByAttendantName(List<DataEntry> coll){
    int compateTo(DataEntry a, DataEntry b){
      DataEntryCell userNameA = a.columns.where((DataEntryCell cell) => cell.column == 'Attendant').first;
      DataEntryCell userNameB = b.columns.where((DataEntryCell cell) => cell.column == 'Attendant').first;
      return userNameA.value.toString().compareTo(userNameB.value.toString());
    }

    coll.sort((DataEntry a, DataEntry b) => compateTo(a,b));
    return coll;
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