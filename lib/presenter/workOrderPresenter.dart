import 'dart:async';

import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';
import 'package:techviz/service/workOrderService.dart';

import '../session.dart';

abstract class WorkOrderPresenterView {
  void onTaskTypeLoaded(List<TaskType> taskTypeList);
}

class WorkOrderPresenter{
  WorkOrderPresenterView _view;
  final ITaskTypeRepository _taskTypeRepository = Repository().taskTypeRepository;
  IWorkOrderService workOrderService;

  WorkOrderPresenter(this._view, {this.workOrderService}){
    workOrderService = workOrderService ?? WorkOrderService();
  }

  void loadTaskType(){
    _taskTypeRepository.getAll(lookup: TaskTypeLookup.workType).then((List<TaskType> list){
      _view.onTaskTypeLoaded(list);
    });
  }

  Future create(TaskType taskType, {String location, String mNumber, String notes, DateTime dueDate}){
    Completer _completer = Completer<void>();

    workOrderService.create(
        Session().user.userID,
        taskType.taskTypeId,
        location: location,
        mNumber: mNumber,
        notes: notes,
        dueDate: dueDate).then((dynamic v){

      _completer.complete();
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }
}