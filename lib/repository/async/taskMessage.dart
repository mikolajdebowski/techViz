import 'dart:async';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/async/basicRemoteChannel.dart';
import 'package:techviz/repository/async/messageClient.dart';
import 'package:techviz/repository/local/taskTable.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class TaskMessage implements IMessageClient<dynamic,void> {
  @override
  Future<void> publishMessage(dynamic object, {String deviceID}) {
    return BasicRemoteChannel<void>().publishMessage(
      object,
      "mobile.task.update",
      "techViz",
    );
  }

  @override
  void bind(Function callbackFnc) async {

    void callbackFunction(Map<String,dynamic> task) async {

      Map<String,dynamic> taskMapped = Map<String,dynamic>();
      taskMapped['_ID'] = task['_ID'];
      taskMapped['_DIRTY'] = false;
      taskMapped['_VERSION'] =  task['_version'];
      taskMapped['USERID'] = task['userID'];
      taskMapped['LOCATION'] = task['location'];
      taskMapped['TASKASSIGNED'] = task['taskAssigned'];
      taskMapped['TASKCREATED'] = task['taskCreated'];
      taskMapped['TASKSTATUSID'] = task['taskStatusID'];
      taskMapped['TASKTYPEID'] = task['taskTypeID'];
      taskMapped['EVENTDESC'] = task['eventDesc'];
      taskMapped['MACHINEID'] = task['machineID'];
      taskMapped['AMOUNT'] = task['amount'] == null? 0.0: task['amount'];
      taskMapped['PLAYERID'] = task['playerID'];
      taskMapped['PLAYERFIRSTNAME'] = task['firstName'];
      taskMapped['PLAYERFIRSTNAME'] = task['lastName'];
      taskMapped['PLAYERTIER'] = task['tier'];
      taskMapped['PLAYERTIERCOLORHEX'] = task['tierColorHex'];

      //print("FROM MAPPED => ID: ${task['_ID']} STATUSID: ${task['taskStatusID']}");

      await TaskTable.insertOrUpdate([taskMapped]);

      Task taskUpdate = await TaskRepository().getTask(task["_ID"].toString());

      //print("AFTER UPDATE AND RETRIEVE =>  ID: ${taskUpdate.id} STATUSID: ${taskUpdate.taskStatus.id}");

      callbackFnc(taskUpdate);
    }


    DeviceInfo info = await Utils.deviceInfo;

    RoutingKeyCallback routingKeyCallback = RoutingKeyCallback();
    routingKeyCallback.routingKeyName = "mobile.task.${info.DeviceID}";
    routingKeyCallback.callbackFunction = callbackFunction;


    MessageClient().bindRoutingKey(routingKeyCallback);

  }
}