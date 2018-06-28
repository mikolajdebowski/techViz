import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/config.dart';
import 'package:techviz/login.dart';

class Splash extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => SplashState();
}

class SplashState extends State<Splash>{

  @override
  void initState() {

    Timer(const Duration(seconds: 2), () {
      loadConfig();
    });

    super.initState();
  }


  void loadConfig(){
    SharedPreferences.getInstance().then((onValuePrefs) {
      SharedPreferences prefs = onValuePrefs;
      if (!prefs.getKeys().contains(Config.SERVERURL) || prefs
          .getString(Config.SERVERURL)
          .length == 0) {
        Navigator.push<Config>(
          context,
          MaterialPageRoute(builder: (context) => Config()),
        );
      }
      else {
        Navigator.push<Login>(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Splash', style: TextStyle(fontSize: 30.0)))
    );
  }
}