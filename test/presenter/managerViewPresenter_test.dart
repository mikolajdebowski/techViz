import 'package:techviz/components/dataEntry/dataEntryGroup.dart';
import 'package:techviz/presenter/managerViewPresenter.dart';

class IManagerViewPresenterView implements IManagerViewPresenter{
  @override
  void onLoadError(dynamic error) {
    throw UnimplementedError();
  }

  @override
  void onOpenTasksLoaded(List<DataEntryGroup> list) {
    print('called onOpenTasksLoaded');
  }

  @override
  void onSlotFloorSummaryLoaded(List<DataEntryGroup> list) {
    print('called onSlotFloorSummaryLoaded');
  }

  @override
  void onTeamAvailabilityLoaded(List<DataEntryGroup> list) {
    print('called onTeamAvailabilityLoaded');
  }
}


void main(){

//  test('loadOpenTasks should call back onOpenTasksLoaded', (){
//    ManagerViewPresenter presenter = ManagerViewPresenter(IManagerViewPresenterView());
//    presenter.loadOpenTasks();
//  });

}