import 'dart:async';

import 'package:techviz/bloc/taskViewBloc.dart';
import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/escalationPathRepository.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';

abstract class EscalationPresenterView {
  void onEscalationPathLoaded(List<EscalationPath> escalationPathList);
  void onTaskTypeLoaded(List<TaskType> taskTypeList);
}

class EscalationPresenter{
  EscalationPresenterView _view;
  final EscalationPathRepository _escalationPathRepository = Repository().escalationPathRepository;
  final TaskTypeRepository _taskTypeRepository = Repository().taskTypeRepository;
  final TaskRepository _taskRepository = Repository().taskRepository;

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

  Future escalateTask(Task task){
    return _taskRepository.escalateTask(task.id, task.escalationPath, escalationTaskType: task.escalationTaskType, notes: task.notes
    ).then<void>((dynamic r){
      task.dirty = 2;
      TaskViewBloc().update(task);
      return Future<void>.value();
    });
  }
}