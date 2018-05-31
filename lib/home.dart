import 'package:flutter/material.dart';
import 'package:techviz/components/actionBar.dart';
import 'package:techviz/components/vizElevatedButton.dart';
import 'package:techviz/menu.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  void goToMenu() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Menu()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var leadingMenuButton = new VizElevatedButton(title: 'Menu', onPressed: goToMenu, textColor: Colors.green,);

    return new Scaffold(
      appBar: new ActionBar('TechViz', leadingWidget: leadingMenuButton),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text('main'),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
