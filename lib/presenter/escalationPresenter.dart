import 'dart:async';
import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/escalationPathRepository.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';
import 'package:techviz/service/taskService.dart';

abstract class EscalationPresenterView {
  void onEscalationPathLoaded(List<EscalationPath> escalationPathList);
  void onTaskTypeLoaded(List<TaskType> taskTypeList);
}

class EscalationPresenter{
  EscalationPresenterView _view;
  final EscalationPathRepository _escalationPathRepository = Repository().escalationPathRepository;
  final TaskTypeRepository _taskTypeRepository = Repository().taskTypeRepository;

  EscalationPresenter(this._view);

  void loadEscalationPath(bool techPath){
    _escalationPathRepository.getAll(techPath).then((List<EscalationPath> list){
      _view.onEscalationPathLoaded(list);
    });
  }

  void loadTaskType(){
    _taskTypeRepository.getAll(lookup: TaskTypeLookup.escalationType).then((List<TaskType> list){
      _view.onTaskTypeLoaded(list);
    });
  }

  Future escalateTask(String taskID, EscalationPath path, TaskType taskType, String notes){
    return TaskService().update(taskID, statusID: 5, escalationPath: path, taskType: taskType, notes: notes);
  }
}