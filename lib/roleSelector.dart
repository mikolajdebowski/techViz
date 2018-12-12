import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/home.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/presenter/roleListPresenter.dart';
import 'package:techviz/repository/rabbitmq/channel/userChannel.dart';
import 'package:techviz/repository/session.dart';

class RoleSelector extends StatefulWidget {
  RoleSelector({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RoleSelectorState();
}

class RoleSelectorState extends State<RoleSelector> implements IRoleListPresenter<Role> {
  List<Role> roleList = List<Role>();

  RoleListPresenter roleListPresenter;
  String selectedRoleID;

  List<int> availableViews = [10];

  @override
  void initState(){
    super.initState();

    Session session = Session();
    roleListPresenter = new RoleListPresenter(this);
    roleListPresenter.loadUserRoles(session.user.UserID);

  }

  void validate(BuildContext context) async {
    if(selectedRoleID == null)
      return;

    Session session = Session();
    var toSend = {'userRoleID': selectedRoleID, 'userID': session.user.UserID};

    UserChannel().publishMessage(toSend);

    Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home()));
  }

  @override
  Widget build(BuildContext context) {

    var defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));

    var okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => validate(context), enabled: selectedRoleID != null);

    var body = GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.all(4.0),
      childAspectRatio: 2.0,
      addAutomaticKeepAlives: false,
      crossAxisCount: 3,
      children: roleList.map((Role role) {
        bool selected = selectedRoleID!= null && selectedRoleID ==  role.id.toString();

        bool enabled = false;
        var contains = availableViews.contains(role.id);
        if(contains!=null && contains == true){
          enabled = true;
        }

        return  VizOptionButton(
            role.description,
            onTap: onOptionSelected,
            tag: role.id,
            selected: selected,
        enabled: enabled);
     }).toList());

    var container = Container(
      decoration: defaultBgDeco,
      constraints: BoxConstraints.expand(),
      child: body,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'My Role', titleColor: Colors.blue, isRoot: true, tailWidget:okBtn),
      body:  SafeArea(child: container),
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
  void onRoleListLoaded(List<Role> result) {
    if(result.length==1){
      Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home()));
      return;
    }
    setState(() {
      roleList = result;

      var defaultUserRoleID = Session().user.UserRoleID;
      if(defaultUserRoleID!=null){
        var defaultRole = roleList.where((Role r) => r.id == defaultUserRoleID);
        if(defaultRole!=null){
          selectedRoleID = defaultRole.first.id.toString();
        }
      }
    });
  }
}
