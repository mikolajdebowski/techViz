import 'package:mockito/mockito.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';

class DeviceUtilsMock extends Mock implements IDeviceUtils{

    @override
    DeviceInfo get deviceInfo{
      DeviceInfo deviceInfo = DeviceInfo();
      deviceInfo.DeviceID = '123';
      deviceInfo.Model = 'test';
      deviceInfo.OSVersion = 'os1';
      deviceInfo.OSName = 'osTest';
      deviceInfo.isEmulator = true;
      return deviceInfo;
    }
}