import 'package:mockito/mockito.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';

class DeviceUtilsMock extends Mock implements IDeviceUtils{
  @override
  Future<DeviceInfo> get deviceInfo{
    DeviceInfo deviceInfo = DeviceInfo();
    deviceInfo.DeviceID = '123';
    deviceInfo.Model = 'test';
    deviceInfo.OSVersion = 'os1';
    deviceInfo.OSName = 'osTest';

    return Future<DeviceInfo>.value(deviceInfo);
  }
}