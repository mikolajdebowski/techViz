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


    var searchIcon = new Icon(Icons.search, color: Colors.white);
    var searchIconWidget = new VizElevatedButton(flex: 1, customWidget: searchIcon);

    var zonesWidget = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Text('My Zones', style: const TextStyle(color: Colors.lightGreen)),
        new Text('A B', style: const TextStyle(color: Colors.white, fontSize: 18.0))
      ],
    );

    var statusWidget = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Text('My Status', style: const TextStyle(color: Colors.lightGreen)),
        new Text('Available', style: const TextStyle(color: Colors.white, fontSize: 18.0))
      ],
    );

    var zonesWidgetBtn = new VizElevatedButton(flex: 2, customWidget: zonesWidget);
    var statusWidgetBtn = new VizElevatedButton(flex: 2, customWidget: statusWidget);

    var centralWidgets = <Widget>[
      zonesWidgetBtn,
      new VizElevatedButton(title: 'Jackpot', textColor: Colors.blue, flex: 4),
      statusWidgetBtn,
      searchIconWidget
    ];

    return new Scaffold(
      backgroundColor: Colors.black,
      appBar: new ActionBar('TechViz', leadingWidget: leadingMenuButton, centralWidgets: centralWidgets),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text('home', style: const TextStyle(color: Colors.white)),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
