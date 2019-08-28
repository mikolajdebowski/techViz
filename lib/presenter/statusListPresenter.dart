import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/userStatusRepository.dart';
import 'package:techviz/service/userService.dart';

abstract class IStatusView {
  void onStatusListLoaded(List<UserStatus> result);
  void onLoadError(dynamic error);
}

abstract class IStatusPresenter {
  void loadUserStatus();
  Future<void> update(String userID, {int statusID, String roleID});
}

class StatusPresenter implements IStatusPresenter {
  IStatusView _view;
  UserStatusRepository _repository;
  UserService userService;

  StatusPresenter(this._view, {this.userService}){
    _repository = Repository().userStatusRepository;
    userService = userService ?? UserService();
  }

  @override
  void loadUserStatus(){
    assert(_view != null);
    _repository.getStatuses().then((List<UserStatus> list) {
      _view.onStatusListLoaded(list);
    }).catchError((dynamic onError) {
      print(onError);
      _view.onLoadError(onError);
    });
  }

  @override
  Future<void> update(String userID, {int statusID, String roleID}){
    return userService.update(userID, statusID: statusID, roleID: roleID);
  }
}