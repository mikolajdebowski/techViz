import 'package:techviz/model/role.dart';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/repository/roleRepository.dart';
import 'package:techviz/repository/userRoleRepository.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/service/userService.dart';



abstract class IRoleView {
  void onRoleListLoaded(List<Role> result);
  void onLoadError(dynamic error);

  void onRoleUpdated(String roleID);
  void onRoleUpdateError(dynamic error);
}

abstract class IRolePresenter {
  IRoleView _view;
  void loadUserRoles(String userID);
  void view(IRoleView view);
  void updateRole(String userID, String roleID);
}

class RolePresenter implements IRolePresenter{
  @override
  IRoleView _view;

  UserRoleRepository _userRoleRepository;
  RoleRepository _roleRepository;
  IUserService _userService;

  @override
  void view(IRoleView view) {
    _view = view;
  }

  RolePresenter(){
    _userRoleRepository = Repository().userRolesRepository;
    _roleRepository = Repository().roleRepository;
    _userService = UserService();
  }

  @override
  void loadUserRoles(String userID) async{
    assert(_view != null);

    List<UserRole> userRoleList = await _userRoleRepository.getUserRoles(userID);
    List<String> ids = userRoleList.map<String>((UserRole u) => u.roleID.toString()).toList();
    List<Role> roleList = await _roleRepository.getAll(ids: ids);

    _view.onRoleListLoaded(roleList);
  }

  @override
  void updateRole(String userID, String roleID) {
    _userService.update(userID, roleID: roleID).then((dynamic x){
      _view.onRoleUpdated(roleID);
    }).catchError((dynamic error){

    });

  }

  factory RolePresenter.build() => RolePresenter();
}