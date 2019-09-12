import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/service/Service.dart';
import 'client/MQTTClientService.dart';

abstract class IUserService{
	Future<void> update(String userID, {int statusID, String roleID});
	void listenAsync();
	void cancelListening();
	void dispose();
}

class UserService extends Service implements IUserService{
	static final UserService _instance = UserService._internal();
	factory UserService({IMQTTClientService mqttClientService, IDeviceUtils deviceUtils}) {
		_instance._mqttClientServiceInstance = mqttClientService ??= MQTTClientService();
		_instance._deviceUtils = deviceUtils ?? DeviceUtils();
		assert(_instance._mqttClientServiceInstance!=null);
		return _instance;
	}
	UserService._internal();

	IMQTTClientService _mqttClientServiceInstance;
	IDeviceUtils _deviceUtils;
	final BehaviorSubject<int> _userStatusSubject = BehaviorSubject<int>();
	Stream<dynamic> _localStream;
	Stream<int> get userStatus => _userStatusSubject.stream;

	@override
	Future<void> update(String userID, {int statusID, String roleID}) async{
		assert(userID!=null);
		assert(statusID!=null || roleID!=null);

		DeviceInfo deviceInfo = _deviceUtils.deviceInfo;

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


		return _completer.future.timeout(Service.defaultTimeoutForServices).catchError((dynamic error){
			if(error is TimeoutException){
				throw Exception("Mobile device has not received a response and has time out after ${Service.defaultTimeoutForServices.inSeconds.toString()} seconds. Please check network details and try again.");
			}
		});
	}

  @override
  void cancelListening() {
		String deviceID = _deviceUtils.deviceInfo.DeviceID;
		_mqttClientServiceInstance.unsubscribe('mobile.userstatus.$deviceID');
  }

  @override
  void dispose() {
		_userStatusSubject?.close();
  }

  @override
  void listenAsync() {
		String deviceID = _deviceUtils.deviceInfo.DeviceID;
		_localStream = _mqttClientServiceInstance.subscribe('mobile.userstatus.$deviceID');
		_localStream.listen((dynamic data){
				dynamic json = JsonDecoder().convert(data);
				int userStatusID = json['UserStatusID'];
				_userStatusSubject.add(userStatusID);
		});
  }
}

