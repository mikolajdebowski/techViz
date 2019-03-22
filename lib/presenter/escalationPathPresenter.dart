import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/escalationPathRepository.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';

abstract class IEscalationPathPresenter {
  void onEscalationPathLoaded(List<EscalationPath> escalationPathList);
  void onTaskTypeLoaded(List<TaskType> taskTypeList);
  void onEscalated();
  void onLoadError(dynamic error);
}

class EscalationPathPresenter{
  IEscalationPathPresenter _view;
  EscalationPathRepository _escalationPathRepository = Repository().escalationPathRepository;
  TaskTypeRepository _taskTypeRepository = Repository().taskTypeRepository;
  TaskRepository _taskRepository = Repository().taskRepository;

  EscalationPathPresenter(this._view);

  void loadEscalationPath(){
    _escalationPathRepository.getAll().then((List<EscalationPath> list){
      _view.onEscalationPathLoaded(list);
    });
  }

  void loadTaskType(){
    _taskTypeRepository.getAll(TaskTypeLookup.escalationType).then((List<TaskType> list){
      _view.onTaskTypeLoaded(list);
    });
  }

  void escalateTask(String taskID, EscalationPath escalationPath, {TaskType taskType, String notes} ){
    _taskRepository.escalateTask(taskID, escalationPath, escalationTaskType: taskType, notes: notes).then((dynamic d){
      _view.onEscalated();
    });
  }
}