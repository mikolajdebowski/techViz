import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/repository/session.dart';

class Menu extends StatefulWidget {
  Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Flushbar _loadingBar;

  @override
  void initState() {
    super.initState();
    _loadingBar = VizDialog.LoadingBar(message: 'Sending request...');
  }

  void goToMyProfile(Object tag){
    Navigator.pushReplacementNamed(context, '/profile');
  }

  void goToSettings(){
    //Navigator.pushReplacementNamed(context, '/settings');
  }

  void goToHelp(){
    //Navigator.pushReplacementNamed(context, '/help');
  }

  void goToAbout(Object tag){
    Navigator.pushReplacementNamed(context, '/about');
  }

  void onTapLogOut(Object tag){
    _loadingBar.show(context);

    Session().logOut().then((dynamic d){
      _loadingBar.dismiss();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
    }).catchError((dynamic error){
      _loadingBar.dismiss();
      VizDialog.Alert(context, 'Error', error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    Row rowProfileSettings = Row(
      children: <Widget>[VizOptionButton('My Profile', iconName: 'ic_my_profile.png', flexible: true, onTap: goToMyProfile), VizOptionButton('Settings', iconName: 'ic_settings.png',flexible: true)],
    );

    Row rowHelpAbout = Row(
      children: <Widget>[VizOptionButton('Help', iconName: 'ic_help.png',flexible: true), VizOptionButton('About', iconName: 'ic_about.png', flexible: true, onTap: goToAbout)],
    );


    VizOptionButton rowLogoff = VizOptionButton('Log Out', iconName: 'ic_logout.png', onTap: onTapLogOut, flexible: true);

    Container container = Container(
      child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: <Widget>[Expanded(child: rowProfileSettings), Expanded(child: rowHelpAbout), rowLogoff],
          )),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
    );

    var safe = SafeArea(child: container);
    return Scaffold(backgroundColor: Colors.black, appBar: ActionBar(title: 'Menu'), body: safe);
  }
}
