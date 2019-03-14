import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/escalationPathRepository.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';

abstract class IEscalationPathPresenter {
  void onEscalationPathLoaded(List<EscalationPath> escalationPathList);
  void onTaskTypeLoaded(List<TaskType> taskTypeList);
  void onLoadError(dynamic error);
}

class EscalationPathPresenter{
  IEscalationPathPresenter _view;
  EscalationPathRepository _escalationPathRepository = Repository().escalationPathRepository;
  TaskTypeRepository _taskTypeRepository = Repository().taskTypeRepository;


  EscalationPathPresenter(this._view);

  void loadEscalationPath(){
    _escalationPathRepository.getAll().then((List<EscalationPath> list){
      _view.onEscalationPathLoaded(list);
    });

  }

  void loadTaskType(){
    _taskTypeRepository.getAll().then((List<TaskType> list){
      _view.onTaskTypeLoaded(list);
    });
  }
}