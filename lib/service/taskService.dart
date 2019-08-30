import 'dart:async';
import 'package:rxdart/subjects.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/model/task.dart';
import 'client/MQTTClientService.dart';

abstract class ITaskService{
	Future<int> update(String taskID, {String taskStatusID});
	StreamSubscription<List<Task>> listen(Function onData);
	void cancelListening();
}

class TaskService implements ITaskService{
	static final TaskService _instance = TaskService._internal();
	factory TaskService({IMQTTClientService mqttClientService, IDeviceUtils deviceUtils}) {
		_instance._mqttClientServiceInstance ??= mqttClientService;
		_instance._deviceUtils ??= deviceUtils;

		assert(_instance._mqttClientServiceInstance!=null);
		assert(_instance._deviceUtils!=null);

		return _instance;
	}
	TaskService._internal();

	IMQTTClientService _mqttClientServiceInstance;
	IDeviceUtils _deviceUtils;
	StreamController<List<Task>> _streamController;
	@override
	Future<int> update(String taskID, {String taskStatusID}) async{
		assert(taskID!=null);

		String routingKeyForPublish = 'mobile.task.update';
		DeviceInfo deviceInfo = await _deviceUtils.deviceInfo;
		Map<String,dynamic> message = <String,dynamic>{};
		message['deviceID'] = deviceInfo.DeviceID;
		message['taskID'] = taskID;

		return _mqttClientServiceInstance.publishMessage(routingKeyForPublish, message);
	}

  @override
  StreamSubscription<List<Task>> listen(Function onData) {
		if(_streamController ==null || _streamController.isClosed){
			_streamController = StreamController<List<Task>>();
		}
		return _streamController.stream.listen(onData);
  }

  @override
  void cancelListening() {
		_streamController?.close();
  }
}

