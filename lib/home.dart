import 'package:flutter/material.dart';
import 'package:techviz/components/VizSearch.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizExpandedButton.dart';
import 'package:techviz/components/vizSelector.dart';
import 'package:techviz/components/vizElevatedButton.dart';
import 'package:techviz/menu.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {

  String currentZones = 'A B';
  String currentStatus = 'Available';

  var availableZones = [
    new VizSelectorOption("A", "A"),
    new VizSelectorOption("B", "B"),
    new VizSelectorOption("C", "C"),
    new VizSelectorOption("D", "D"),
    new VizSelectorOption("E", "E"),
  ];

  var availableStatuses = [
    new VizSelectorOption("1", "Available"),
    new VizSelectorOption("2", "Off-shift"),
  ];


  void goToMenu() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Menu()),
    );
  }


  void onZoneSelectorCallbackOK(List<VizSelectorOption> selected) {
    setState(() {
      currentZones = "";

      if(selected.length>4){
        currentZones = "4+";
      }
      else{
        selected.forEach((element) {
          currentZones += element.description + " ";
        });
        currentZones = currentZones.trim();
      }
    });
  }

  void goToZonesSelector() {
    var selector = new VizSelector(title: 'My Zones', multiple: true, onOKTapTapped: onZoneSelectorCallbackOK, options: availableZones);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => selector),
    );
  }

  void goToStatusSelector() {
    var selector = new VizSelector(title: 'My Status');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => selector),
    );
  }

  void goToSearchSelector() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new VizSearch(title: 'Search...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    var leadingMenuButton = new VizExpandedButton(title: 'Menu', onTap: goToMenu, textColor: Colors.green,);

    var zonesWidget = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text('My Zones', style: const TextStyle(color: Colors.lightGreen)),
        new Text(currentZones, style: const TextStyle(color: Colors.white, fontSize: 20.0))
      ],
    );

    var statusWidget = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text('My Status', style: const TextStyle(color: Colors.lightGreen)),
        new Text(currentStatus, style: const TextStyle(color: Colors.white, fontSize: 20.0))
      ],
    );


    //ZONES AND STATUS
    var zonesWidgetBtn = new VizExpandedButton(flex: 2, customWidget: zonesWidget, onTap: goToZonesSelector);
    var statusWidgetBtn = new VizExpandedButton(flex: 2, customWidget: statusWidget, onTap: goToStatusSelector);


    //SEARCH
    var searchIcon = new Icon(Icons.search, color: Colors.white);
    var searchIconWidget = new VizExpandedButton(flex: 1, customWidget: searchIcon, onTap: goToSearchSelector);

    var centralWidgets = <Widget>[
      zonesWidgetBtn,
      new VizExpandedButton(title: 'Jackpot', textColor: Colors.blue, flex: 4),
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
