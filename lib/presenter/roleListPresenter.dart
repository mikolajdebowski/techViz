import 'package:techviz/model/role.dart';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/repository/roleRepository.dart';
import 'package:techviz/repository/userRoleRepository.dart';
import 'package:techviz/repository/repository.dart';



abstract class IRoleListView<Role> {
  void onRoleListLoaded(List<Role> result);
  void onLoadError(dynamic error);
}

abstract class IRoleListPresenter {
  IRoleListView<Role> _view;
  void loadUserRoles(String userID);
  void view(IRoleListView view);
}

class RoleListPresenter implements IRoleListPresenter{
  @override
  IRoleListView<Role> _view;

  UserRoleRepository _userRoleRepository;
  RoleRepository _roleRepository;

  @override
  void view(IRoleListView view) {
    _view = view;
  }

  RoleListPresenter(){
    _userRoleRepository = Repository().userRolesRepository;
    _roleRepository = Repository().roleRepository;
  }

  @override
  void loadUserRoles(String userID) async{
    assert(_view != null);

    List<UserRole> userRoleList = await _userRoleRepository.getUserRoles(userID);
    List<String> ids = userRoleList.map<String>((UserRole u) => u.roleID.toString()).toList();
    List<Role> roleList = await _roleRepository.getAll(ids: ids);

    _view.onRoleListLoaded(roleList);
  }

  factory RoleListPresenter.build() => RoleListPresenter();

}