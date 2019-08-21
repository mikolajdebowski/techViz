import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:techviz/ui/about.dart';
import 'package:techviz/ui/config.dart';
import 'package:techviz/ui/logging.dart';
import 'package:techviz/ui/login.dart';
import 'package:techviz/ui/profile.dart';
import 'package:techviz/repository/async/MessageClient.dart';
import 'package:techviz/ui/splash.dart';

import 'common/utils.dart';
import 'service/MQTTClient.dart';

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
  StreamController<dynamic> controller1;
  StreamController<dynamic> controller2;
  @override
  void initState() {
    super.initState();

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      Utils.saveLog('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

    WidgetsBinding.instance.addObserver(this);

    MQTTClient mqttClient = MQTTClient();
    //mqttClient.init('ws://tvdev/mqtt', 'EMULATOR').then((void v){
    mqttClient.init('tvdev.internal.bis2.net', 'EMULATOR').then((void v){
      String routingKey = 'mobile.machineStatus';
      //mqttClient.subscribe(routingKey);
      mqttClient.subscribe('topic/topic1');

//      controller1 = StreamController<dynamic>();
//      controller1.addStream(mqttClient.streamFor(routingKey));
//      controller1.stream.listen((dynamic data){
//        print('from controller 1 ${data.toString()}');
//      });
//
//      controller2 = StreamController<dynamic>();
//      controller2.addStream(mqttClient.streamFor(routingKey));
//      controller2.stream.listen((dynamic data){
//        print('from controller 2 ${data.toString()}');
//      });

      Future.delayed(Duration(seconds: 10), (){
        print('unsubscribing...');
        mqttClient.unsubscribe('topic/topic1');
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    controller1?.close();
    controller2?.close();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {

      if(_lastLifecycleState == AppLifecycleState.inactive && state == AppLifecycleState.resumed){
        MessageClient().Connect();
      }
      _lastLifecycleState = state;
      print(_lastLifecycleState);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black
      ),
      debugShowCheckedModeBanner: false,
      title: 'TechViz',
      home: Splash(),
      routes: <String, WidgetBuilder> {
        '/login': (BuildContext context) => Login(),
        '/config': (BuildContext context) => Config(),
        '/profile': (BuildContext context) => Profile(),
        '/logging': (BuildContext context) => Logging(),
        '/about': (BuildContext context) => About(),
      },
    );
  }
}
