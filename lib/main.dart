import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techviz/config.dart';
import 'package:techviz/home.dart';
import 'package:techviz/login.dart';
import 'package:techviz/menu.dart';
import 'package:techviz/profile.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/splash.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {

      if(_lastLifecycleState == AppLifecycleState.inactive && state == AppLifecycleState.resumed){
        Session().rabbitmqClient.then((Client client){
          Session().UpdateConnectionStatus(ConnectionStatus.Connecting);
          print('Reconnecting...');
          client.connect().catchError((dynamic err){
            Session().UpdateConnectionStatus(ConnectionStatus.Offline);
            print(err);
          }).then((dynamic d){
            Channel channel = d as Channel;
            Session().UpdateConnectionStatus(ConnectionStatus.Online);
            print(channel);
          });
        });
      }

      _lastLifecycleState = state;
      print(_lastLifecycleState);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
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
