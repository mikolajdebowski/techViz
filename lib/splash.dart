import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/config.dart';
import 'package:techviz/login.dart';

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashState();
}

class SplashState extends State<Splash> {
  @override
  void initState() {
    Timer(const Duration(seconds: 1), () {
      loadConfig();
    });

    super.initState();
  }

  void loadConfig() {
    SharedPreferences.getInstance().then((onValuePrefs) {
      SharedPreferences prefs = onValuePrefs;
      if (!prefs.getKeys().contains(Config.SERVERURL) || prefs.getString(Config.SERVERURL).length == 0) {

        Navigator.pushReplacement(context, MaterialPageRoute<Config>(builder: (BuildContext context) => Config()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute<Login>(builder: (BuildContext context) => Login()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Image.asset('assets/images/splash.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center),
    );
  }
}
