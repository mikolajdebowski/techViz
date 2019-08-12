import 'dart:async';

import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';
import 'package:techviz/repository/workOrder.repository.dart';

import '../session.dart';

abstract class WorkOrderPresenterView {
  void onTaskTypeLoaded(List<TaskType> taskTypeList);
}

class WorkOrderPresenter{
  WorkOrderPresenterView _view;
  final ITaskTypeRepository _taskTypeRepository = Repository().taskTypeRepository;
  final IWorkOrderRepository _workOrderRepository = Repository().workOrderRepository;
  WorkOrderPresenter(this._view);

  void loadTaskType(){
    _taskTypeRepository.getAll(lookup: TaskTypeLookup.workType).then((List<TaskType> list){
      _view.onTaskTypeLoaded(list);
    });
  }

  Future create(TaskType taskType, {String location, String mNumber, String notes, DateTime dueDate}){
    Completer _completer = Completer<void>();

    _workOrderRepository.create(
        Session().user.userID,
        taskType.taskTypeId,
        location: location,
        mNumber: mNumber,
        notes: notes,
        dueDate: dueDate).then((dynamic v){
      int validmachine = v['validmachine'];
      if(validmachine==0){
        _completer.completeError('Invalid Location/Asset Number');
        return;
      }

      _completer.complete();
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }
}