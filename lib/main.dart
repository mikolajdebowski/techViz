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
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

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

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      Utils.saveLog('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

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
