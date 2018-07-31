import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizElevated.dart';

class Menu extends StatefulWidget {
  Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {


  void logOut(){
    //clear
    Navigator.pushReplacementNamed(context, '/login');
  }


  @override
  Widget build(BuildContext context) {
    Row rowProfileSettings = Row(
      children: <Widget>[VizButton('My Profile', iconName: 'ic_my_profile.png'), VizButton('Settings', iconName: 'ic_settings.png')],
    );
    Row rowHelpAbout = Row(
      children: <Widget>[VizButton('Help', iconName: 'ic_help.png'), VizButton('About', iconName: 'ic_about.png')],
    );
    VizButton rowLogoff = VizButton('Log Out', iconName: 'ic_logout.png', onTap: logOut);

    Container container = Container(
      child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: <Widget>[Expanded(child: rowProfileSettings), Expanded(child: rowHelpAbout), rowLogoff],
          )),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
    );

    return Scaffold(backgroundColor: Colors.black, appBar: ActionBar(title: 'Menu'), body: container);
  }
}
