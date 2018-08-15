import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/presenter/roleListPresenter.dart';

class RoleSelector extends StatefulWidget {
  RoleSelector({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RoleSelectorState();
}

class RoleSelectorState extends State<RoleSelector> implements IRoleListPresenter<UserRole> {
  List<UserRole> roleList = List<UserRole>();
  RoleListPresenter roleListPresenter;
  String selectedRoleID;

  List<GlobalKey> listViewKeys = List<GlobalKey>();
  @override
  void initState(){
    super.initState();

    roleListPresenter = new RoleListPresenter(this);
    roleListPresenter.loadUserRoles("irina2");

  }


  void onOkTap() {
    print(selectedRoleID);
    //Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    var defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));

    var okBtn = VizButton('OK', onTap: onOkTap, highlighted: true);

    listViewKeys = List<GlobalKey>();

    var body = GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.all(4.0),
      childAspectRatio: 2.0,
      addAutomaticKeepAlives: false,
      crossAxisCount: 3,
      children: roleList.map((UserRole role) {
        bool selected = selectedRoleID!= null && selectedRoleID ==  role.roleID.toString();

        return  VizOptionButton(
            role.roleDescription,
            onTap: onOptionSelected,
            tag: role.roleID.toString(),
            selected: selected);
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


  void onOptionSelected(String tag){
    setState(() {
      selectedRoleID = tag;
    });
  }

  @override
  void onLoadError(Error error) {
    // TODO: implement onLoadError
  }

  @override
  void onRoleListLoaded(List<UserRole> result) {
    setState(() {
      roleList = result;
    });
  }

  void onSelectAllTapped() {
//    if (options != null) {
//      setState(() {
//        options.forEach((option) {
//          option.selected = true;
//        });
//      });
//    }
  }

  void onSelectNoneTapped() {
//    if (options != null) {
//      setState(() {
//        options.forEach((option) {
//          option.selected = false;
//        });
//      });
//    }
  }



}
