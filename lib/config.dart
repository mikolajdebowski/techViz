import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:techviz/home.dart';

class Config extends StatefulWidget {
  static final String SERVERURL = 'SERVERURL';

  @override
  State<StatefulWidget> createState() => ConfigState();
}

class ConfigState extends State<Config> {
  SharedPreferences prefs;
  final serverAddressController = TextEditingController();

  @override
  void initState() {
    SharedPreferences.getInstance().then((onValue) {
      prefs = onValue;
      if (prefs.getKeys().contains(Config.SERVERURL)) {
        serverAddressController.text = prefs.getString(Config.SERVERURL);
      }
    });

    super.initState();
  }

  void onNextTap() async {
    await prefs.setString(Config.SERVERURL, serverAddressController.text);

    Navigator.push<Home>(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFFD2DEE1), Color(0xFFB2C2CB)],
              begin: Alignment.topCenter,
              end: Alignment.topCenter,
              tileMode: TileMode.repeated)),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 3,
              child: TextField(
                controller: serverAddressController,
                decoration: InputDecoration(hintText: 'Server Address'),
              )),
          Expanded(child: FlatButton(onPressed: onNextTap, child: Text('Next')))
        ],
      ),
    ));
  }
}
