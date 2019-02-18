
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/processor/processorSlotMachineRepository.dart';

abstract class ISlotMachinePresenter<SlotMachine> {
  void onSlotMachinesLoaded(List<SlotMachine> result);
  void onLoadError(Error error);
}

class SlotMachinePresenter{

  ISlotMachinePresenter<SlotMachine> _view;
  ProcessorSlotMachineRepository _repo;

  SlotMachinePresenter(this._view){
    _repo = ProcessorSlotMachineRepository();
  }

  void search({String query}) async {
    assert(_view != null);

    //List<SlotMachine> list = await _repo.search(query);

    _view.onSlotMachinesLoaded([]);
  }
}


class RoleModelPresenter{

}