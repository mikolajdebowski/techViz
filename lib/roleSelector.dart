import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/home.dart';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/presenter/roleListPresenter.dart';
import 'package:techviz/repository/session.dart';

class RoleSelector extends StatefulWidget {
  RoleSelector({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RoleSelectorState();
}

class RoleSelectorState extends State<RoleSelector> implements IRoleListPresenter<UserRole> {
  List<UserRole> roleList = List<UserRole>();
  RoleListPresenter roleListPresenter;
  String selectedRoleID;

  @override
  void initState(){
    super.initState();

    Session session = Session();
    roleListPresenter = new RoleListPresenter(this);
    roleListPresenter.loadUserRoles(session.user.UserID);
  }

  void validate(BuildContext context) {
    if(selectedRoleID == null)
      return;

    Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home()));
  }

  @override
  Widget build(BuildContext context) {

    var defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));

    var okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => validate(context));

    var body = GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.all(4.0),
      childAspectRatio: 2.0,
      addAutomaticKeepAlives: false,
      crossAxisCount: 3,
      children: roleList.map((UserRole role) {
        bool selected = selectedRoleID!= null && selectedRoleID ==  role.roleID.toString();

        bool enabled = false;
        var where = AvailableViews.values.where((e)=>e.toString() == "AvailableViews.${role.roleDescription}");
        if(where!=null && where.length>0){
          enabled = true;
        }

        return  VizOptionButton(
            role.roleDescription,
            onTap: onOptionSelected,
            tag: role.roleID.toString(),
            selected: selected,
        enabled: enabled);
     }).toList());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'My Role', titleColor: Colors.blue, isRoot: true, tailWidget:okBtn),
      body: Container(
        decoration: defaultBgDeco,
        constraints: BoxConstraints.expand(),
        child: body,
      ),
    );
  }

  void onOptionSelected(Object tag){
    setState(() {
      selectedRoleID = tag.toString();
    });
  }

  @override
  void onLoadError(Error error) {
    // TODO: implement onLoadError
  }

  @override
  void onRoleListLoaded(List<UserRole> result) {
    if(result.length==1){
      Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home()));
      return;

    }
    setState(() {
      roleList = result;
    });
  }
}


enum AvailableViews{
  Attendant,
}
