import 'package:synchronized/synchronized.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/cache/cacheData.dart';

class SlotMachineCache extends CacheData<SlotMachine>{

  static final SlotMachineCache _singleton = SlotMachineCache._internal();
  factory SlotMachineCache() {
    return _singleton;
  }

  SlotMachineCache._internal();

  void updateEntry(SlotMachine received, String from){
    var lock = Lock();
    lock.synchronized((){
      int idx = data.indexWhere((SlotMachine _sm) => _sm.standID == received.standID);
      if (idx >= 0) {
        if (received.updatedAt.compareTo(data[idx].updatedAt) >= 0) {
          data[idx].machineStatusID = received.machineStatusID;
          data[idx].updatedAt = received.updatedAt;
        }
      }
      else{
        data.add(received);
      }
    });
  }
}


