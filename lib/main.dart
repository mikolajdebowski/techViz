import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techviz/config.dart';
import 'package:techviz/home.dart';
import 'package:techviz/login.dart';
import 'package:techviz/menu.dart';
import 'package:techviz/profile.dart';
import 'package:techviz/repository/async/MessageClient.dart';
import 'package:techviz/splash.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(TechVizApp());
  });
}

class TechVizApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TechVizAppState();
}

class TechVizAppState extends State<TechVizApp> with WidgetsBindingObserver {
  AppLifecycleState _lastLifecycleState;
  StreamSubscription<ConnectivityResult> connectionSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

//    connectionSubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//      print(result);
//      if(result == ConnectivityResult.wifi || result == ConnectivityResult.mobile){
//        MessageClient().Init();
//      }
//    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    //connectionSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {

      if(_lastLifecycleState == AppLifecycleState.inactive && state == AppLifecycleState.resumed){
        MessageClient().Init();
      }
      _lastLifecycleState = state;
      print(_lastLifecycleState);
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechViz',
      home: Splash(),
      routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => Home(),
        '/menu': (BuildContext context) => Menu(),
        '/login': (BuildContext context) => Login(),
        '/config': (BuildContext context) => Config(),
        '/profile': (BuildContext context) => Profile()
      },
    );
  }
}
