import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter_is_emulator/flutter_is_emulator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'model/deviceInfo.dart';

abstract class IDeviceUtils{
	DeviceInfo get deviceInfo;
	Future<DeviceInfo> init();
}
class DeviceUtils implements IDeviceUtils{
	DeviceInfo _deviceInfo;

	static final DeviceUtils _singleton = DeviceUtils._internal();
	factory DeviceUtils() {
		return _singleton;
	}
	DeviceUtils._internal();

	@override
	Future<DeviceInfo> init() async{
		DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
		_deviceInfo = DeviceInfo();

		if(Platform.isIOS){
			IosDeviceInfo ios = await deviceInfoPlugin.iosInfo;
			_deviceInfo.DeviceID = ios.identifierForVendor;
			_deviceInfo.Model = ios.model;
			_deviceInfo.OSVersion = ios.systemVersion;
			_deviceInfo.OSName = ios.systemName;
		}
		else {
			AndroidDeviceInfo android = await deviceInfoPlugin.androidInfo;
			if (android.id == 'MASTER' || android.manufacturer == 'unknown') {
				SharedPreferences prefs = await SharedPreferences.getInstance();
				if (prefs.getKeys().contains("UUID")) {
					_deviceInfo.DeviceID = prefs.getString("UUID");
				}
				else {
					var uuid = Uuid();
					String strUUID = uuid.v4().toString().toUpperCase();
					prefs.setString("UUID", strUUID);
					_deviceInfo.DeviceID = strUUID;
				}
			}
			else _deviceInfo.DeviceID = android.id;

			_deviceInfo.Model = android.model;
			_deviceInfo.OSVersion = android.version.release;
			_deviceInfo.OSName = android.brand;
		}

		_deviceInfo.isEmulator = await FlutterIsEmulator.isDeviceAnEmulatorOrASimulator;

		return Future<DeviceInfo>.value(_deviceInfo);
	}

  @override
  DeviceInfo get deviceInfo{
		assert(_deviceInfo!=null);
		return _deviceInfo;
	}
}