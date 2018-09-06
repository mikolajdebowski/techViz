import 'package:techviz/model/role.dart';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/repository/roleRepository.dart';
import 'package:techviz/repository/userRoleRepository.dart';
import 'package:techviz/repository/repository.dart';

abstract class IRoleListPresenter<Role> {
  void onRoleListLoaded(List<Role> result);
  void onLoadError(Error error);
}

class RoleListPresenter{

  IRoleListPresenter<Role> _view;
  UserRoleRepository _userRoleRepository;
  RoleRepository _roleRepository;

  RoleListPresenter(this._view){
    _userRoleRepository = Repository().userRolesRepository;
    _roleRepository = Repository().rolesRepository;
  }

  void loadUserRoles(String userID) async{
    assert(_view != null);

    List<UserRole> userRoleList = await _userRoleRepository.getUserRoles(userID);
    List<String> ids = userRoleList.map<String>((UserRole u) => u.roleID.toString()).toList();
    List<Role> roleList = await _roleRepository.getAll(ids: ids);

    _view.onRoleListLoaded(roleList);
  }
}


class RoleModelPresenter{

}