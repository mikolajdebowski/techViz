import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter_is_emulator/flutter_is_emulator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'model/deviceInfo.dart';

abstract class IDeviceUtils{
	Future<bool> get isEmulator;
	Future<DeviceInfo> get deviceInfo;
}
class DeviceUtils implements IDeviceUtils{
	@override
	Future<bool> get isEmulator => FlutterIsEmulator.isDeviceAnEmulatorOrASimulator;

	@override
	Future<DeviceInfo> get deviceInfo async {
		DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
		DeviceInfo info = DeviceInfo();

		if(Platform.isIOS){
			IosDeviceInfo ios = await deviceInfoPlugin.iosInfo;
			info.DeviceID = ios.identifierForVendor;
			info.Model = ios.model;
			info.OSVersion = ios.systemVersion;
			info.OSName = ios.systemName;
		}
		else {
			AndroidDeviceInfo android = await deviceInfoPlugin.androidInfo;
			if (android.id == 'MASTER' || android.manufacturer == 'unknown') {
				SharedPreferences prefs = await SharedPreferences.getInstance();
				if (prefs.getKeys().contains("UUID")) {
					info.DeviceID = prefs.getString("UUID");
				}
				else {
					var uuid = Uuid();
					String strUUID = uuid.v4().toString().toUpperCase();
					prefs.setString("UUID", strUUID);
					info.DeviceID = strUUID;
				}
			}
			else info.DeviceID = android.id;
			info.Model = android.model;
			info.OSVersion = android.version.release;
			info.OSName = android.brand;
		}
		return info;
	}
}