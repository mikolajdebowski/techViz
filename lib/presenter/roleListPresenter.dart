import 'package:techviz/model/userRole.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/userRoleRepository.dart';
import 'package:techviz/repository/repository.dart';

abstract class IRoleListPresenter<UserRole> {
  void onRoleListLoaded(List<UserRole> result);
  void onLoadError(Error error);
}

class RoleListPresenter{

  IRoleListPresenter<UserRole> _view;
  UserRoleRepository _repository;

  RoleListPresenter(this._view){
    _repository = Repository().userRolesRepository;
  }

  void loadUserRoles(String userID){
    assert(_view != null);
    _repository.getUserRoles(userID).then((List<UserRole> list) {
      _view.onRoleListLoaded(list);

    }).catchError((Error onError) {
      print(onError);
      _view.onLoadError(onError);
    });
  }
}