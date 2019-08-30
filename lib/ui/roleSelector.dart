import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizSnackbar.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/ui/home.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/presenter/rolePresenter.dart';
import 'package:techviz/session.dart';

class RoleSelector extends StatefulWidget {
  final IRolePresenter rolePresenter;

  const RoleSelector({this.rolePresenter, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RoleSelectorState(rolePresenter ?? RolePresenter.build());
}

class RoleSelectorState extends State<RoleSelector> implements IRoleView {
  List<Role> roleList = <Role>[];
  IRolePresenter rolePresenter;
  String selectedRoleID;
  RoleSelectorState(this.rolePresenter);
  VizSnackbar _snackbar;

  @override
  void initState() {
    super.initState();

    Session session = Session();

    rolePresenter.view(this);
    rolePresenter.loadUserRoles(session.user.userID);
  }

  void validate(BuildContext context) async {
    if(selectedRoleID == null)
      return;

    _snackbar = VizSnackbar.Processing('Updating...');
    _snackbar.show(context);

    rolePresenter.updateRole(Session().user.userID, selectedRoleID);
  }

  void goToHomeGivingRole(Role role){
    HomeViewType homeViewType;
    if(role.isManager || role.isSupervisor || role.isTechSupervisor || role.isTechManager){
      homeViewType = HomeViewType.ManagerView;
    }else if(role.isAttendant || role.isTechnician){
      homeViewType = HomeViewType.TaskView;
    }
    assert(homeViewType!=null);

    Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home(homeViewType)));
  }

  @override
  Widget build(BuildContext context) {

    BoxDecoration defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: const [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));

    VizButton okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => validate(context), enabled: selectedRoleID != null);

    Widget body;

    if(roleList.isNotEmpty){
      body = GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.all(4.0),
          childAspectRatio: 2.0,
          addAutomaticKeepAlives: false,
          crossAxisCount: 3,
          children: roleList.map((Role role) {
            bool selected = selectedRoleID!= null && selectedRoleID ==  role.id.toString();

            return  VizOptionButton(
              role.description,
              onTap: onOptionSelected,
              tag: role.id,
              selected: selected,
            );
          }).toList());
    }
    else{
      body = Center(child: Text('No roles available for the user'));
    }


    Container container = Container(
      decoration: defaultBgDeco,
      constraints: BoxConstraints.expand(),
      child: body,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'My Role', titleColor: Colors.blue, tailWidget:okBtn),
      body:  SafeArea(child: container),
    );
  }

  void onOptionSelected(Object tag){
    setState(() {
      selectedRoleID = tag.toString();
    });
  }

  @override
  void onLoadError(dynamic error) {
    print(error);
  }

  @override
  void onRoleListLoaded(List<Role> result) {
    if(result.length==1){
      goToHomeGivingRole(result[0]);
      return;
    }

    setState(() {
      roleList = result;
      var defaultUserRoleID = Session().user.userRoleID;
      if(defaultUserRoleID!=null){
        Iterable<Role> defaultRole = roleList.where((Role r) => r.id == defaultUserRoleID);
        if(defaultRole.isNotEmpty){
          selectedRoleID = defaultRole.first.id.toString();
        }
        else{
          selectedRoleID = null;
        }
      }
    });
  }

  @override
  void onRoleUpdated(String roleID) async {
    _snackbar?.dismiss();
    Session().role = (await Repository().roleRepository.getAll(ids: [selectedRoleID])).first;
    Session().user.userRoleID =  Session().role.id;
    goToHomeGivingRole(Session().role);
  }

  @override
  void onRoleUpdateError(dynamic error) {
    _snackbar?.dismiss();
    VizDialog.Alert(context, 'Error', error.toString());
  }
}
