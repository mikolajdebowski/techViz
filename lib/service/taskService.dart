import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:synchronized/synchronized.dart';
import 'client/MQTTClientService.dart';

abstract class ITaskService{
	Future update(String taskID, {int statusID, String notes, String userID, EscalationPath escalationPath, TaskType taskType});
	void listenAsync();
	void cancelListening();
	void dispose();
}

class TaskService implements ITaskService{
	static final TaskService _instance = TaskService._internal();
	factory TaskService({IMQTTClientService mqttClientService, IDeviceUtils deviceUtils}) {
		_instance._mqttClientServiceInstance = mqttClientService!=null? mqttClientService : MQTTClientService();
		assert(_instance._mqttClientServiceInstance!=null);
		return _instance;
	}
	TaskService._internal();

	IMQTTClientService _mqttClientServiceInstance;
	final BehaviorSubject<List<Task>> _openTasksSubject = BehaviorSubject<List<Task>>();
	Stream<dynamic> _localStream;
	Stream<List<Task>> get openTasks => _openTasksSubject.stream;
	List<Task> _taskList = [];
	final _lock = Lock();

  @override
  void listenAsync() {
		String deviceID = DeviceUtils().deviceInfo.DeviceID;

		_localStream = _mqttClientServiceInstance.subscribe('mobile.opentasks.$deviceID');
		_localStream.listen((dynamic data){
			dynamic json = JsonDecoder().convert(data);
			List<Task> outputList = [];

			(json['tasks'] as List).forEach((dynamic jsonTask){
				Task localTask = _getLocalTask(jsonTask['_ID']);
				int remoteTaskVersion = jsonTask['_Version'] as int;
				if(localTask==null || remoteTaskVersion>localTask.version){
					Task remoteTask = _toTaskParser(jsonTask, task: localTask);
					outputList.add(remoteTask);
				}
				else{
					outputList.add(localTask);
				}
			});

			_taskList = outputList;
			_openTasksSubject.add(_taskList);
		});
  }

  Task _getLocalTask(String taskID){
		Iterable<Task> where = _taskList.where((Task local)=> local.id == taskID);
		return where!=null && where.isNotEmpty ? where.first: null;
	}

  Task _toTaskParser(Map jsonTask, {Task task}){
		task ??= Task();

		task.id = jsonTask['_ID'];
		task.dirty = 0;
		task.version = jsonTask['_Version'] as int;
		task.userID = jsonTask['UserId'];
		task.location = jsonTask['location'];
		task.taskCreated = jsonTask['taskCreated']!=null && jsonTask['taskCreated'].toString().isNotEmpty ? DateTime.parse(jsonTask['taskCreated']) : null;
		task.taskAssigned = jsonTask['taskAssigned']!=null && jsonTask['taskAssigned'].toString().isNotEmpty ? DateTime.parse(jsonTask['taskAssigned']) : null;

		task.taskTypeID = jsonTask['taskTypeID'];
		task.taskType = TaskType(jsonTask['taskTypeID'], jsonTask['taskTypeDescription'].toString(), null);

		task.taskStatusID = jsonTask['taskStatusID'];
		task.taskStatus = TaskStatus(id: jsonTask['taskStatusID'], description: jsonTask['taskStatusDescription'].toString());

		task.taskUrgencyID = jsonTask['taskUrgencyID'];
		task.eventDesc = jsonTask['eventDesc'];

		task.machineId = jsonTask['machineID'].toString();
		task.amount = jsonTask['amount']!=null && jsonTask['amount'].toString().isNotEmpty ? double.parse(jsonTask['amount'].toString()): 0.0;

		task.playerID = jsonTask['playerID'];
		task.isTechTask = jsonTask['isTechTask'] == 1;
		task.playerFirstName = jsonTask['firstName'];
		task.playerLastName = jsonTask['lastName'];
		task.playerTier =  jsonTask['tier'];
		task.playerTierColorHEX = jsonTask['tierColorHex'];

		return task;
	}

	@override
	Future update(String taskID, {int statusID, String notes, String userID, EscalationPath escalationPath, TaskType taskType}) async{
		assert(taskID!=null);

		Completer _completer = Completer<int>();

		int _localTaskIdx;
		await _lock.synchronized(() async {
			_localTaskIdx = _taskList.indexWhere((Task local)=> local.id == taskID);
		});

		if(_localTaskIdx<0){
			throw TaskNotAvailableException();
		}

		String routingKeyForPublish = 'mobile.task.update';
		Map<String,dynamic> message = <String,dynamic>{};
		message['deviceID'] = DeviceUtils().deviceInfo.DeviceID;
		message['taskID'] = taskID;
		if(statusID!=null)
			message['taskStatusId'] = statusID;
		if(notes!=null)
			message['tasknote'] = notes;
		if(userID!=null){
			message['userId'] = userID;
		}
		if(escalationPath!=null){
			message['EscalationPath'] = escalationPath.id;
		}
		if(taskType!=null){
			message['EscalationTypeID'] = taskType.taskTypeId;
		}

		try{
			_mqttClientServiceInstance.publishMessage(routingKeyForPublish, message);

			await _lock.synchronized(() async {
				_taskList[_localTaskIdx].dirty = 1;
			});
			_openTasksSubject.add(_taskList);
			_completer.complete();
		}
		catch(error){
			_completer.completeError(error);
		}

		return _completer.future.timeout(Duration(seconds: 10));
	}

  @override
  void cancelListening() async {
		String deviceID = DeviceUtils().deviceInfo.DeviceID;
		_mqttClientServiceInstance.unsubscribe('mobile.opentasks.$deviceID');
  }

  @override
  void dispose(){
		_openTasksSubject?.close();
	}

	@visibleForTesting
	void inject(String taskID, String location, String userID, int taskStatusID){
		Task newTask = Task(dirty: 0, id: taskID, location: location, userID: userID, taskStatus: TaskStatus(id: taskStatusID), taskStatusID: taskStatusID);
		_taskList.add(newTask);
		_openTasksSubject.add(_taskList);
	}
}

class TaskNotAvailableException implements Exception{
	String cause = 'This task is not available anymore';
	TaskNotAvailableException();

	@override
	String toString() {
		return cause.toString();
	}
}