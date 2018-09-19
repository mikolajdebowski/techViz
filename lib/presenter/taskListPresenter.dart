import 'package:techviz/model/task.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/repository/repository.dart';

abstract class ITaskListPresenter<Task> {
  void onTaskListLoaded(List<Task> result);
  void onLoadError(Error error);
}

class TaskListPresenter{

  ITaskListPresenter<Task> _view;
  TaskRepository _repository;

  TaskListPresenter(this._view){
   _repository = new Repository().taskRepository;
  }

  void loadTaskList(String userID){
    assert(_view != null);
    _repository.getTaskList(userID).then((List<Task> list) {
      _view.onTaskListLoaded(list);

    }).catchError((Error onError) {
      print(onError);
      _view.onLoadError(onError);
    });
  }
}
