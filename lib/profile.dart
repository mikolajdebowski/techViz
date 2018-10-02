import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'dart:math';
import 'package:techviz/presenter/roleListPresenter.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/statusListPresenter.dart';

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

  @override
  void initState() {

    Session session = Session();
    roleListPresenter = new RoleListPresenter(this);
    roleListPresenter.loadUserRoles(session.user.UserID);

    statusListPresenter = StatusListPresenter(this);
    statusListPresenter.loadUserRoles(session.user.UserID);


    Map<String, String> usrMap = {
      'UserID': session.user.UserID,
      'UserName': session.user.UserName,
      'UserRoleID': session.user.UserRoleID.toString(),
      'UserStatusID': session.user.UserStatusID.toString(),
    };

    setState(() {
      usrMap.forEach((k,v) {
        var item = ProfileItem(columnName: '${k}', value: '${v}');
        _userInfo.add(item);
      });

    });


    super.initState();
  }

  Widget _buildProfileItem(BuildContext context, int index) {
    return Container(
      height: 70.0,
      margin: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
      color: (index % 2 == 0 ? Color(0xFFeff4f5) : Color(0xFFffffff)),
      child: ListTile(
        title: Text(_userInfo[index].columnName),
        subtitle: Text(_userInfo[index].value),
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

  @override
  Widget build(BuildContext context) {
    var leftPanel = Expanded(flex: 1, child: _buildProfileList());

    var rightPanel = Expanded(
      flex: 1,
      child: Column(
        children: <Widget>[
          Container(
            child: Image.asset("assets/images/my_profile_graph.png"),
          ),
        ],
      ),
    );

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
  void onLoadError(Error error) {
    // TODO: implement onLoadError
  }

  @override
  void onRoleListLoaded(List<Role> result) {
    if (result.length == 1) {
      return;
    }

    Session session = Session();
    var user = session.user;

    print("roles loaded");

//    setState(() {
//      roleList = result;
//    });
  }

  @override
  void onStatusListLoaded(List<UserStatus> result) {
    // TODO: implement onStatusListLoaded

    Session session = Session();
    var user = session.user;

    print("statuses loaded");
//    setState(() {
//      roleList = result;
//    });
  }
}

abstract class ListItem {}

// A ListItem that contains data to display a message
class ProfileItem implements ListItem {
  final String columnName;
  final String value;

//  final String UserID;
//  final String UserName;
//  final String UserRoleID;
//  final String UserStatusID;

// instantiation
//  Expanded(child: Products(products, deleteProduct:deleteProduct))

  // in class contructror
//  final List<Map<String, String>> products;
//  final Function deleteProduct;
//
//  Products(this.products, {this.deleteProduct});

//  const User({this.UserID, this.UserName, this.UserRoleID, this.UserStatusID});
  ProfileItem({this.columnName, this.value});
}
