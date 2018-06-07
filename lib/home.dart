import 'dart:math';

import 'package:flutter/material.dart';
import 'package:techviz/components/vizSearch.dart';
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

  String currentZones = '-';
  String currentStatus = 'Available';
  var availableZones = new List<VizSelectorOption>();

  var availableStatuses = [
    new VizSelectorOption("1", "Available"),
    new VizSelectorOption("2", "Off shift"),
  ];


  _HomeState(){
    for(var i = 0; i < 1000; i++){
      availableZones.add(new VizSelectorOption(i.toString(), i.toString()));
    }
  }


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

  void onMyStatusSelectorCallbackOK(List<VizSelectorOption> selected) {
    setState(() {
      currentStatus = "";

      if(selected.length>4){
        currentStatus = "4+";
      }
      else{
        selected.forEach((element) {
          currentStatus += element.description + " ";
        });
        currentStatus = currentStatus.trim();
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
    var selector = new VizSelector(title: 'My Status', onOKTapTapped: onMyStatusSelectorCallbackOK,  options: availableStatuses);
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
    var leadingMenuButton = new VizExpandedButton(title: 'Menu', onTap: goToMenu, textColor: const Color(0xFF159680));

    var zonesWidget = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text('My Zones', style: const TextStyle(color: Colors.lightGreen, fontSize: 12.0)),
        new Text(currentZones, style: const TextStyle(color: Colors.white, fontSize: 18.0), overflow: TextOverflow.ellipsis)
      ],
    );

    var statusWidget = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text('My Status', style: const TextStyle(color: Colors.lightGreen, fontSize: 12.0)),
        new Text(currentStatus, style: const TextStyle(color: Colors.white, fontSize: 18.0), overflow: TextOverflow.ellipsis)
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
