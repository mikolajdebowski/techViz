import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/userStatusRepository.dart';

abstract class IStatusListPresenter<UserStatus> {
  void onStatusListLoaded(List<UserStatus> result);
  void onLoadError(dynamic error);
}

class StatusListPresenter{
  IStatusListPresenter<UserStatus> _view;
  UserStatusRepository _repository;

  StatusListPresenter(this._view){
    _repository = Repository().userStatusRepository;
  }

  void loadUserStatus(){
    assert(_view != null);
    _repository.getStatuses().then((List<UserStatus> list) {
      _view.onStatusListLoaded(list);
    }).catchError((dynamic onError) {
      print(onError);
      _view.onLoadError(onError);
    });
  }
}