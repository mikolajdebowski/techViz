import 'dart:async';

import 'package:techviz/model/task.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/common/repositoryContract.dart';
import 'package:techviz/repository/repository.dart';

class TaskPresenter{

  RepositoryContract<Task> _view;
  IRepository _repository;

  TaskPresenter(this._view){
    _repository = new Repository().taskRepository;
  }

  void loadData(){
    assert(_view != null);
    _repository.fetch().then((List<dynamic> list) {
      _view.onLoadData(list as List<Task>);

    }).catchError((Error onError) {
      print(onError);
      _view.onLoadError(onError);
    });
  }
}