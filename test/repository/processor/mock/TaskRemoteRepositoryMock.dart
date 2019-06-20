import 'package:techviz/repository/taskRepository.dart';

class TaskRemoteRepositoryMock implements ITaskRemoteRepository{
  @override
  Future fetch() {
    List<Map<String,dynamic>> listToReturn = <Map<String,dynamic>>[];

    for(int i =0; i< 100; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['_ID'] = i.toString();
      mapEntry['Location'] = i.toString();
      mapEntry['TaskTypeID'] = i.toString();
      mapEntry['TaskStatusID'] = '1';
      mapEntry['UserID'] = i.toString();
      mapEntry['ElapsedTime'] = i.toString();
      mapEntry['TaskUrgencyID'] = i.toString();
      mapEntry['ParentID'] = i.toString();
      mapEntry['IsTechTask'] = false;
      listToReturn.add(mapEntry);
    }

    return Future<List<Map<String,dynamic>>>.value(listToReturn);
  }

  @override
  Future openTasksSummary() {

    List<Map<String,dynamic>> listToReturn = <Map<String,dynamic>>[];

    //100 Open TASKS
    for(int i =0; i< 100; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['_ID'] = i.toString();
      mapEntry['Location'] = i.toString();
      mapEntry['TaskTypeID'] = i.toString();
      mapEntry['TaskStatusID'] = i%2==0? '1' : '7';
      mapEntry['UserID'] = i.toString();
      mapEntry['ElapsedTime'] = i.toString();
      mapEntry['TaskUrgencyID'] = i.toString();
      mapEntry['ParentID'] = i.toString();
      mapEntry['IsTechTask'] = false;
      listToReturn.add(mapEntry);
    }

    //20 Unassigned TASKS
    for(int i =0; i< 20; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['_ID'] = i.toString();
      mapEntry['Location'] = i.toString();
      mapEntry['TaskTypeID'] = i.toString();
      mapEntry['TaskStatusID'] = i%2==0? '1' : '7';
      mapEntry['UserID'] = i%2==0? null : '';
      mapEntry['ElapsedTime'] = i.toString();
      mapEntry['TaskUrgencyID'] = i.toString();
      mapEntry['ParentID'] = i.toString();
      mapEntry['IsTechTask'] = false;
      listToReturn.add(mapEntry);
    }

    //20 Overdue TASKS
    for(int i =0; i< 20; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['_ID'] = i.toString();
      mapEntry['Location'] = i.toString();
      mapEntry['TaskTypeID'] = i.toString();
      mapEntry['TaskStatusID'] = '3';
      mapEntry['UserID'] = i.toString();
      mapEntry['ElapsedTime'] = i.toString();
      mapEntry['TaskUrgencyID'] = i.toString();
      mapEntry['ParentID'] = i.toString();
      mapEntry['IsTechTask'] = false;
      listToReturn.add(mapEntry);
    }

    //10 Escalated TASKS
    for(int i =0; i< 20; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['_ID'] = i.toString();
      mapEntry['Location'] = i.toString();
      mapEntry['TaskTypeID'] = i.toString();
      mapEntry['TaskStatusID'] = '3';
      mapEntry['UserID'] = i.toString();
      mapEntry['ElapsedTime'] = i.toString();
      mapEntry['TaskUrgencyID'] = i.toString();
      mapEntry['ParentID'] = i.toString();
      mapEntry['IsTechTask'] = true;
      listToReturn.add(mapEntry);
    }


    return Future<List<Map<String,dynamic>>>.value(listToReturn);
  }
}