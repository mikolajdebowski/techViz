import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/vizSnackbar.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/ui/taskView.dart';
import '../session.dart';
import 'home.dart';
import 'managerView.dart';


class MenuDrawer extends StatefulWidget {
  final GlobalKey holderKey;
  const MenuDrawer(this.holderKey);

  @override
  State<StatefulWidget> createState() => MenuDrawerState();
}

class MenuDrawerState extends State<MenuDrawer> {
  final Color bgColor = Color(0xFFEAEDF2);
  final Color headerBorderColor = Color(0xFFCCCCCC);
  final Color selectedFontColor = Color(0xFF415990);


  bool get hasAccessToManagerView{
    Role role = Session().role;
    return role.isManager || role.isSupervisor || role.isTechManager || role.isTechSupervisor;
  }

  bool get hasAccessToTaskView{
    Role role = Session().role;
    return role.isAttendant || role.isTechnician;
  }

  @override
  Widget build(BuildContext context) {
    String userName = Session().user.userName;
    String userID = Session().user.userID;

    List<Widget> menuChildren = [];
    menuChildren.add(Container(
      margin: EdgeInsets.only(bottom: 5),
      constraints: BoxConstraints.expand(height: 60),
      decoration: BoxDecoration(color: bgColor, border: Border(bottom: BorderSide(color: headerBorderColor))),
      child: Padding(
        padding: EdgeInsets.only(left: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              userName,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
            Text('$userID')
          ],
        ),
      ),
    ));


    if(hasAccessToTaskView){
      menuChildren.add(MenuDrawerItem('My Tasks', (){
        Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home(HomeViewType.TaskView)));
      }, selected: widget.holderKey is LabeledGlobalKey<TaskViewState>));
    }

    if(hasAccessToManagerView){
      menuChildren.add(MenuDrawerItem('Manager Summary', (){
        Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home(HomeViewType.ManagerView)));
      }, selected: widget.holderKey is LabeledGlobalKey<ManagerViewState>));
    }

    menuChildren.add(MenuDrawerItem('My Profile', (){
      Navigator.pushNamed(context, '/profile');
    }));
    menuChildren.add(MenuDrawerItem('Settings', (){}, disabled: true));
    menuChildren.add(MenuDrawerItem('Help', (){}, disabled: true));

    return Drawer(
      child: Container(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: menuChildren,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: logOut,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('LOG OUT', style: TextStyle(color: Colors.red)),
                  ),
                ),
              )
            ],
          ),
          constraints: BoxConstraints.expand()),
    );
  }

  void logOut(){
      final VizSnackbar _processingBar = VizSnackbar.Loading('Logging out...');
      _processingBar.show(context);

      Session().logOut().then((dynamic d){
        _processingBar.dismiss();
        Navigator.pushReplacementNamed(context, '/login');
      }).catchError((dynamic error){
        VizSnackbar.Error(error.toString()).show(context);
      });
  }


}



class MenuDrawerItem extends StatelessWidget{
  final Color bgColor = Color(0xFFEAEDF2);
  final Color selectedFontColor = Color(0xFF415990);

  final String text;
  final Function onItemTap;
  final bool selected;
  final bool disabled;

  MenuDrawerItem(this.text, this.onItemTap, {this.selected = false, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: SizedBox(
        width: double.infinity,
        child: Material(
            color: selected ? bgColor : Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(3)),
            child: InkWell(
              onTap: onItemTap,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(text, style: TextStyle(color: disabled ? Colors.grey : selected ? selectedFontColor : Colors.black)),
              ),
            )
        ),
      ),
    );
  }

}