import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/vizSnackbar.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/ui/taskView.dart';
import 'package:techviz/ui/workOrder.dart';
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
              key: Key('userNameText'),
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
            Text('$userID', key: Key('userIDText'))
          ],
        ),
      ),
    ));


    if(hasAccessToTaskView){
      menuChildren.add(MenuDrawerItem('My Tasks', (){
        Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home(HomeViewType.TaskView)));
      }, selected: widget.holderKey is LabeledGlobalKey<TaskViewState>, key: Key('myTasksItemKey')));
    }

    if(hasAccessToManagerView){
      menuChildren.add(MenuDrawerItem('Manager Summary', (){
        Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home(HomeViewType.ManagerView)));
      }, selected: widget.holderKey is LabeledGlobalKey<ManagerViewState>, key: Key('managerSummaryItemKey')));
    }

    menuChildren.add(MenuDrawerItem('Create Work Order', (){
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute<Home>(builder: (BuildContext context) => WorkOrder()));
    }));

    menuChildren.add(MenuDrawerItem('My Profile', (){
      Navigator.pushNamed(context, '/profile');
    }, key: Key('myProfileItemKey')));
    menuChildren.add(MenuDrawerItem('Settings', (){}, disabled: true, key: Key('settingsItemKey')));
    menuChildren.add(MenuDrawerItem('Help', (){}, disabled: true, key: Key('helpItemKey')));
    menuChildren.add(MenuDrawerItem('About', (){}, disabled: true, key: Key('aboutItemKey')));


    menuChildren.add(Align(
      alignment: Alignment.bottomCenter,
      child: InkWell(
        key: Key('logoutKey'),
        onTap: logOut,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text('LOG OUT', style: TextStyle(color: Colors.red)),
        ),
      ),
    ));

    return Drawer(
      child: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: menuChildren,
            ),
          ),
          constraints: BoxConstraints.expand()),
    );
  }

  void logOut(){
      final VizSnackbar _processingBar = VizSnackbar.Processing('Logging out...');
      _processingBar.show(context);
      print('logout tapped');
      Session().logOut().then((dynamic d){
        print('logOut session finished');

        _processingBar.dismiss();
        Navigator.pushReplacementNamed(context, '/login');
      }).catchError((dynamic error){
        VizSnackbar.Error(error.toString()).show(context);
      });
  }
}



class MenuDrawerItem extends StatelessWidget{
  final Color selectedBackgroundColor = Color(0xFFEAEDF2);
  final Color selectedFontColor = Color(0xFF415990);

  final String text;
  final Function onItemTap;
  final bool selected;
  final bool disabled;

  MenuDrawerItem(this.text, this.onItemTap, {this.selected = false, this.disabled = false, Key key}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: SizedBox(
        width: double.infinity,
        child: Material(
            color: selected ? selectedBackgroundColor : Colors.white,
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