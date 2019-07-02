import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/roleRepository.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:techviz/ui/home.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/presenter/roleListPresenter.dart';
import 'package:techviz/session.dart';

class RoleSelector extends StatefulWidget {
  final IRoleListPresenter roleListPresenter;

  RoleSelector({this.roleListPresenter, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RoleSelectorState(roleListPresenter ?? RoleListPresenter.build());
}

class RoleSelectorState extends State<RoleSelector> implements IRoleListView<Role> {
  List<Role> roleList = <Role>[];

  IRoleListPresenter roleListPresenter;
  String selectedRoleID;

  RoleSelectorState(this.roleListPresenter);

  @override
  void initState() {
    super.initState();

    Session session = Session();

    roleListPresenter.view(this);
    roleListPresenter.loadUserRoles(session.user.userID);
  }

  void validate(BuildContext context) async {
    if(selectedRoleID == null)
      return;

    Session session = Session();
    UserRepository userRepository = Repository().userRepository;

    await userRepository.update(session.user.userID, roleID: selectedRoleID);

    session.role = (await Repository().roleRepository.getAll(ids: [selectedRoleID])).first;
    session.user.userRoleID =  session.role.id;

    Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home()));
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
      Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home()));
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
}
