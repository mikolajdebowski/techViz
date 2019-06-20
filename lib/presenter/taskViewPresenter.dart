import 'package:techviz/model/task.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskRepository.dart';

abstract class ITaskViewPresenter<Task> {
  void onTaskListLoaded(List<Task> result);
  void onLoadError(dynamic error);
}

class TaskViewPresenter{

  ITaskViewPresenter<Task> _view;
  TaskRepository _repository;

  TaskViewPresenter(this._view){
   _repository = Repository().taskRepository;
  }

  void loadTaskList(String userID){
    assert(_view != null);
    _repository.getOpenTasks(userID).then((List<Task> list) {
      _view.onTaskListLoaded(list);

    }).catchError((dynamic onError) {
      print(onError);
      _view.onLoadError(onError);
    });
  }
}
