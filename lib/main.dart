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

        Session().ResetRabbitmqClient();
        Session().UpdateConnectionStatus(ConnectionStatus.Connecting);
        print('Reconnecting...');

        Session().rabbitmqClient.then((Client client) async {
          Session().initRabbitMQ().then((dynamic d){
            Session().UpdateConnectionStatus(ConnectionStatus.Online);
          });
        }).catchError((dynamic err){
          print(err);
          Session().UpdateConnectionStatus(ConnectionStatus.Offline);
          showModalBottomSheet<String>(
              context: context,
              builder: (BuildContext context) {
                return Center(
                    child: Padding(
                      padding: EdgeInsets.all(80.0),
                      child: Text(err.toString()),
                    ));
              });
        });
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
