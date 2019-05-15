
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/repository/userRepository.dart';

abstract class IReassignPresenter {
  void onUserLoaded(List<User> list);
  void onLoadError(dynamic error);
}

class ReassignPresenter {
  IReassignPresenter _view;

  ReassignPresenter(this._view) {
    assert(_view != null);
  }

  void loadUsers() {
    UserRepository _repository = Repository().userRepository;
    _repository.allUsers().then((List<User> list){
      this._view.onUserLoaded(list);
    });
  }

  Future reassign(String taskID, String userID){
    TaskRepository repo = Repository().taskRepository;
    return repo.reassign(taskID, userID);
  }
}