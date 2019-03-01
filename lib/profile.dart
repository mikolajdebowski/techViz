import 'dart:async' show Future;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/roleListPresenter.dart';
import 'package:techviz/presenter/statusListPresenter.dart';
import 'package:techviz/repository/processor/processorUserGeneralInfoRepository.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/repository/userGeneralInfoRepository.dart';
import 'package:techviz/stats.dart';
/// Bar chart example

/// Bar chart example


class Profile extends StatefulWidget {
  Profile() {}

  @override
  State<StatefulWidget> createState() {
    return ProfileState();
  }
}

class ProfileState extends State<Profile>
    implements IRoleListPresenter<Role>, IStatusListPresenter<UserStatus> {
  List<ProfileItem> _userInfo = [];
  RoleListPresenter roleListPresenter;
  StatusListPresenter statusListPresenter;
  List<Role> rolesList = List<Role>();
  List<UserStatus> userStatusList = List<UserStatus>();
  String _currentRole;
  String _currentStatus;

  void changedStatusDropDownItem(String selectedStatus) {
    setState(() {
      _currentStatus = selectedStatus;
    });
  }

  void changedRoleDropDownItem(String selectedRole) {
    setState(() {
      _currentRole = selectedRole;
    });
  }

  @override
  void initState(){

    rolesList.add(Role());
    userStatusList.add(UserStatus());

    Session session = Session();
    roleListPresenter = RoleListPresenter(this);
    roleListPresenter.loadUserRoles(session.user.UserID);

    statusListPresenter = StatusListPresenter(this);
    statusListPresenter.loadUserRoles(session.user.UserID);

    Map<String, String> usrMap = {
      'UserID': session.user.UserID,
      'UserName': (session.user.UserName != null) ? session.user.UserName: "",
      'UserRoleID': session.user.UserRoleID.toString(),
      'UserStatusID': session.user.UserStatusID.toString(),
    };

    setState(() {
      usrMap.forEach((k, v) {
        var item = ProfileItem(columnName: '${k}', value: '${v}');
        _userInfo.add(item);
      });
    });

    super.initState();
  }


  Widget _buildProfileItem(BuildContext context, int index) {

    Widget subItem;
    if(_userInfo[index].columnName == 'UserStatusID'){
//      subItem = DropdownButton(
//        value: _currentStatus,
//        items: userStatusList.map((UserStatus status){
//          return DropdownMenuItem(
//            value: '${status.description}',
//            child: Text('${status.description}'),
//          );
//        }).toList(),
//        onChanged: changedStatusDropDownItem,
//      );

      if(_currentStatus != null)
        subItem = Text(_currentStatus);
      else
        subItem = Text("");

    }else if(_userInfo[index].columnName == 'UserRoleID'){
//      subItem = DropdownButton(
//        value: _currentRole,
//        items: rolesList.map((Role val){
//          return DropdownMenuItem(
//            value: '${val.description}',
//            child: Text('${val.description}'),
//          );
//        }).toList(),
//        onChanged: changedRoleDropDownItem,
//      );

      if(_currentRole != null)
        subItem = Text(_currentRole);
      else
        subItem = Text("");
    }
    else{
      subItem = Text(_userInfo[index].value);
    }

    return Container(
      height: 70.0,
      margin: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
      color: (index % 2 == 0 ? Color(0xFFeff4f5) : Color(0xFFffffff)),
      child: ListTile(
        title: Text(_userInfo[index].columnName),
        subtitle: subItem,
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
    print('fetchUserInfo');
    await loadInitialData();

  }

  Future<void> loadInitialData() async{
    await userGeneralInfoRepository.fetch();
  }



  UserGeneralInfoRepository get userGeneralInfoRepository {
    return UserGeneralInfoRepository(remoteRepository: ProcessorUserGeneralInfoRepository());
  }

  @override
  Widget build(BuildContext context) {
    var leftPanel = Expanded(flex: 1, child: _buildProfileList());
    var rightPanel = Expanded(flex: 2, child: Stats());

    Container container = Container(
      child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Row(
            children: <Widget>[leftPanel, rightPanel],
          )),
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
    if (result.length == 1) {
      return;
    }

    setState(() {
      rolesList = result;

      Session session = Session();
      User user = session.user;
      rolesList.forEach((Role role) {
        if(role.id.toString() == user.UserStatusID.toString()){
          _currentRole = role.description;
        }
      });
    });
  }

  @override
  void onStatusListLoaded(List<UserStatus> result) {
    if (result.length == 1) {
      return;
    }

    setState(() {
      userStatusList = result;

      Session session = Session();
      User user = session.user;
      userStatusList.forEach((UserStatus status) {
        if(status.id.toString() == user.UserStatusID.toString()){
          _currentStatus = status.description;
        }
      });

    });

//    print('done');
  }
}

abstract class ListItem {}

// A ListItem that contains data to display a message
class ProfileItem implements ListItem {
  final String columnName;
  final String value;

  ProfileItem({this.columnName, this.value});
}
