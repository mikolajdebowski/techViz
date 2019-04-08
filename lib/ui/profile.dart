import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/roleListPresenter.dart';
import 'package:techviz/presenter/statusListPresenter.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/ui/stats.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfileState();
}

class ProfileState extends State<Profile> implements IRoleListPresenter<Role>, IStatusListPresenter<UserStatus> {
  List<ProfileItem> _userInfo = [];
  RoleListPresenter roleListPresenter;
  StatusListPresenter statusListPresenter;

  List<UserStatus> _statuses;
  List<Role> _roles;

  @override
  void initState(){
    super.initState();

    Session session = Session();
    roleListPresenter = RoleListPresenter(this);
    roleListPresenter.loadUserRoles(session.user.userID);

    statusListPresenter = StatusListPresenter(this);
    statusListPresenter.loadUserRoles(session.user.userID);

    _userInfo.add(ProfileItem(columnName: 'UserID', value: session.user.userID));
    _userInfo.add(ProfileItem(columnName: 'UserName', value: session.user.userName));
    _userInfo.add(ProfileItem(columnName: 'UserRoleID', value: session.user.userRoleID));
    _userInfo.add(ProfileItem(columnName: 'UserStatusID', value: session.user.userStatusID));
    _userInfo.add(ProfileItem(columnName: 'StaffID', value: session.user.staffID));
  }


  Widget _buildProfileItem(BuildContext context, int index) {

    Widget subItem;
    if(_userInfo[index].columnName == 'UserStatusID'){
      if(_statuses==null || _statuses.length==0){
        subItem = Center(child: CircularProgressIndicator());
      }
      else{
        int id = _userInfo[index].value as int;
        String statusDescription = _statuses.where((UserStatus status) => status.id == id.toString()).first.description;
        subItem = Text(statusDescription);
      }
    }
    else if(_userInfo[index].columnName == 'UserRoleID'){
      if(_roles==null || _roles.length==0){
        subItem = Center(child: CircularProgressIndicator());
      }
      else{
        int id = _userInfo[index].value;
        String roleDescription = _roles.where((Role role) => role.id == id).first.description;
        subItem = Text(roleDescription);
      }
    }
    else{
      subItem = Text(_userInfo[index].value);
    }

    return Container(
      color: (index % 2 == 0 ? Color(0xFFeff4f5) : Color(0xFFffffff)),
      child: ListTile(
        title: Text(_userInfo[index].columnName),
        subtitle: Padding(padding: EdgeInsets.only(left: 10.0, top: 5.0), child: subItem),
      ),
    );
  }

  Widget _buildProfileList() {
    Widget list;
    if (_userInfo.length > 0) {
      list = ListView.builder(
        itemCount: _userInfo.length,
        itemBuilder: _buildProfileItem,
      );
    } else {
      list = Center(
        child: Text('No profile info to render'),
      );
    }

    return list;
  }

  void fetchUserInfo() async{
    //await Repository().userSkillsRepository.fetch();
  }

  @override
  Widget build(BuildContext context) {
    var leftPanel = Expanded(flex: 1, child: _buildProfileList());
    var rightPanel = Expanded(flex: 2, child: Stats());

    Container container = Container(
      child: Row(
        children: <Widget>[leftPanel, rightPanel],
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF586676), Color(0xFF8B9EA7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.repeated)),
    );

    var safe = SafeArea(child: container, top: false, bottom: false);
    return Scaffold(backgroundColor: Colors.black, appBar: ActionBar(title: 'My Profile'), body: safe);
  }

  @override
  void onLoadError(dynamic error) {
    // TODO: implement onLoadError
  }

  @override
  void onRoleListLoaded(List<Role> result) {
    setState(() {
      _roles = result;
    });
  }

  @override
  void onStatusListLoaded(List<UserStatus> result) {
    setState(() {
      _statuses = result;
    });
  }
}

abstract class ListItem {}

class ProfileItem implements ListItem {
  final String columnName;
  final dynamic value;

  ProfileItem({this.columnName, this.value});
}
