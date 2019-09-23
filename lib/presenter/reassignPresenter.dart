import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:techviz/service/taskService.dart';
import 'package:techviz/viewmodel/reassignUsers.dart';

abstract class IReassignPresenter {
  void onUserLoaded(List<ReassignUser> list);
  void onLoadError(dynamic error);
}

class ReassignPresenter {
  final IReassignPresenter _view;

  ReassignPresenter(this._view) {
    assert(_view != null);
  }

  void loadUsers() {
    UserRepository _repository = Repository().userRepository;


    _repository.usersBySectionsByTaskCount().then((List<Map> list){

      List<ReassignUser> toReturn = list.map((Map map) => ReassignUser.fromMap(map)).toList();
      _view.onUserLoaded(toReturn);

    });
  }

  Future reassign(String taskID, String userID){
    return TaskService().update(taskID, userID: userID);
  }
}