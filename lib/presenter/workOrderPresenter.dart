import 'dart:async';

import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';

abstract class WorkOrderPresenterView {
  void onTaskTypeLoaded(List<TaskType> taskTypeList);
}

class WorkOrderPresenter{
  WorkOrderPresenterView _view;
  final TaskTypeRepository _taskTypeRepository = Repository().taskTypeRepository;

  WorkOrderPresenter(this._view);

  void loadTaskType(){
    _taskTypeRepository.getAll(lookup: TaskTypeLookup.workType).then((List<TaskType> list){
      _view.onTaskTypeLoaded(list);
    });
  }

  Future create(TaskType taskType, {String location, String assetNumber, String notes, DateTime dueDate}){
    Completer _completer = Completer<void>();



    Future<void>.delayed(Duration(seconds: 2), (){
      _completer.completeError('ops');
    });

    return _completer.future;
  }
}