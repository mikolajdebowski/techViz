import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/roleListPresenter.dart';
import 'package:techviz/presenter/statusListPresenter.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/stats.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfileState();
}

class ProfileState extends State<Profile> implements IRoleListPresenter<Role>, IStatusListPresenter<UserStatus> {
  List<ProfileItem> _userInfo = [];
  RoleListPresenter roleListPresenter;
  StatusListPresenter statusListPresenter;
  String _currentRole;
  String _currentStatus;

  @override
  void initState(){
    super.initState();

    Session session = Session();
    roleListPresenter = RoleListPresenter(this);
    roleListPresenter.loadUserRoles(session.user.UserID);

    statusListPresenter = StatusListPresenter(this);
    statusListPresenter.loadUserRoles(session.user.UserID);

    _userInfo.add(ProfileItem(columnName: 'UserID', value: session.user.UserID));
    _userInfo.add(ProfileItem(columnName: 'UserName', value: session.user.UserName));
    _userInfo.add(ProfileItem(columnName: 'UserRoleID', value: session.user.UserRoleID.toString()));
    _userInfo.add(ProfileItem(columnName: 'UserStatusID', value: session.user.UserStatusID.toString()));
    _userInfo.add(ProfileItem(columnName: 'StaffID', value: session.user.StaffID));
  }


  Widget _buildProfileItem(BuildContext context, int index) {

    Widget subItem;
    if(_userInfo[index].columnName == 'UserStatusID'){
      if(_currentStatus != null)
        subItem = Text(_currentStatus);
      else
        subItem = Center(child: CircularProgressIndicator());

    }else if(_userInfo[index].columnName == 'UserRoleID'){
      if(_currentRole != null)
        subItem = Text(_currentRole);
      else
        subItem = Center(child: CircularProgressIndicator());
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
    if (result.length == 0) {
      return;
    }

    result.forEach((Role role) {
      if(role.id.toString() == Session().user.UserStatusID.toString()){
        setState(() {
          _currentRole = role.description;
        });
      }
    });
  }

  @override
  void onStatusListLoaded(List<UserStatus> result) {
    if (result.length == 0) {
      return;
    }

    result.forEach((UserStatus status) {
      if(status.id.toString() == Session().user.UserStatusID.toString()){
        setState(() {
          _currentStatus = status.description;
        });
        return;
      }
    });
  }
}

abstract class ListItem {}

class ProfileItem implements ListItem {
  final String columnName;
  final String value;

  ProfileItem({this.columnName, this.value});
}
