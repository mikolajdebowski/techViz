import 'dart:async';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'client/MQTTClientService.dart';

abstract class IUserService{
	Future<void> update(String userID, {int statusID, String roleID});
}

class UserService implements IUserService{
	IMQTTClientService _mqttClientServiceInstance;
	IDeviceUtils _deviceUtils;

	UserService({IMQTTClientService mqttClientService, IDeviceUtils deviceUtils}){
		_mqttClientServiceInstance = mqttClientService!=null? mqttClientService : MQTTClientService();
		_deviceUtils = deviceUtils!=null? deviceUtils : DeviceUtils();

		assert(_mqttClientServiceInstance!=null);
	}

	@override
	Future<void> update(String userID, {int statusID, String roleID}) async{
		assert(userID!=null);
		assert(statusID!=null || roleID!=null);

		DeviceInfo deviceInfo = await _deviceUtils.deviceInfo;

		Completer _completer = Completer<void>();
		String routingKeyForPublish = 'mobile.user.update';
		String routingKeyForCallback = 'mobile.user.update.${deviceInfo.DeviceID}';

		_mqttClientServiceInstance.subscribe(routingKeyForCallback);
		_mqttClientServiceInstance.streams(routingKeyForCallback).listen((dynamic responseCallback){
			_mqttClientServiceInstance.unsubscribe(routingKeyForCallback);
			_completer.complete();
		});

		Map<String,dynamic> message = <String,dynamic>{};
		message['deviceID'] = deviceInfo.DeviceID;
		message['userID'] = userID;
		if(statusID!=null)
			message['userStatusID'] = statusID;
		if(roleID!=null)
			message['userRoleID'] = roleID;

		_mqttClientServiceInstance.publishMessage(routingKeyForPublish, message);

		return _completer.future.timeout(Duration(seconds: 10));
	}
}

