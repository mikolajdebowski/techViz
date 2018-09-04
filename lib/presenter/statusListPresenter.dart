import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/userStatusRepository.dart';

abstract class IStatusListPresenter<UserStatus> {
  void onStatusListLoaded(List<UserStatus> result);
  void onLoadError(Error error);
}

class StatusListPresenter{
  IStatusListPresenter<UserStatus> _view;
  //IUserStatusRepository _repository;

  StatusListPresenter(this._view){
    //_repository = new Repository().userStatusRepository;
  }

  void loadUserRoles(String userID){
    assert(_view != null);
//    _repository.getStatuses().then((List<UserStatus> list) {
//      _view.onStatusListLoaded(list);
//    }).catchError((Error onError) {
//      print(onError);
//      _view.onLoadError(onError);
//    });
  }
}