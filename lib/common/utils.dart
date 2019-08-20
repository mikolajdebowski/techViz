import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_is_emulator/flutter_is_emulator.dart';
import 'package:path_provider/path_provider.dart';
import 'appInfo.dart';
import 'deviceInfo.dart';

class Utils {
  static Future<bool> get isEmulator {
    return FlutterIsEmulator.isDeviceAnEmulatorOrASimulator;
  }

  static Future<DeviceInfo> get deviceInfo async {
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


  static Future<AppInfo> get packageInfo async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppInfo info = AppInfo();
    info.appName = packageInfo.appName;
    info.packageName = packageInfo.packageName;
    info.version = packageInfo.version;
    info.buildNumber = packageInfo.buildNumber;

    return info;
  }

  static void saveLog(String log) async{
    print('writing $log}');
    final file = await _file;
    file.writeAsString('$log\n', mode: FileMode.append, flush: true);
  }

  static Future<String> readLog() async{
    final file = await _file;
    return file.readAsString();
  }

  static Future<bool> clearLog() async{
    final file = await _file;
    return file.delete().then((FileSystemEntity ent){
      return Future.value(true); //?
    });
  }

  static Future<File> get _file async {
    var _dirPath = await getApplicationDocumentsDirectory();
    String _path = _dirPath.path;

    var file = File('$_path/logging.txt');

    // ignore: avoid_slow_async_io
    bool exists = await file.exists();
    if(!exists) {
      file = await file.create();
    }
    return file;
  }


//
//  static Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
//    return <String, dynamic>{
//      'version.securityPatch': build.version.securityPatch,
//      'version.sdkInt': build.version.sdkInt,
//      'version.release': build.version.release,
//      'version.previewSdkInt': build.version.previewSdkInt,
//      'version.incremental': build.version.incremental,
//      'version.codename': build.version.codename,
//      'version.baseOS': build.version.baseOS,
//      'board': build.board,
//      'bootloader': build.bootloader,
//      'brand': build.brand,
//      'device': build.device,
//      'display': build.display,
//      'fingerprint': build.fingerprint,
//      'hardware': build.hardware,
//      'host': build.host,
//      'id': build.id,
//      'manufacturer': build.manufacturer,
//      'model': build.model,
//      'product': build.product,
//      'supported32BitAbis': build.supported32BitAbis,
//      'supported64BitAbis': build.supported64BitAbis,
//      'supportedAbis': build.supportedAbis,
//      'tags': build.tags,
//      'type': build.type,
//      'isPhysicalDevice': build.isPhysicalDevice,
//    };
//  }
//
//  static Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
//    return <String, dynamic>{
//      'name': data.name,
//      'systemName': data.systemName,
//      'systemVersion': data.systemVersion,
//      'model': data.model,
//      'localizedModel': data.localizedModel,
//      'identifierForVendor': data.identifierForVendor,
//      'isPhysicalDevice': data.isPhysicalDevice,
//      'utsname.sysname:': data.utsname.sysname,
//      'utsname.nodename:': data.utsname.nodename,
//      'utsname.release:': data.utsname.release,
//      'utsname.version:': data.utsname.version,
//      'utsname.machine:': data.utsname.machine,
//    };
//  }

}