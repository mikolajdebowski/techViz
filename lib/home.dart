import 'dart:math';

import 'package:flutter/material.dart';
import 'package:techviz/components/vizSearch.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizSelector.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/menu.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String currentZones = '-';
  String currentStatus = 'Available';
  var availableZones = List<VizSelectorOption>();

  var availableStatuses = [
    VizSelectorOption("1", "Available"),
    VizSelectorOption("2", "Off shift"),
  ];

  _HomeState() {
    for (var i = 0; i < 1000; i++) {
      availableZones.add(VizSelectorOption(i.toString(), i.toString()));
    }
  }

  void goToMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Menu()),
    );
  }

  void onZoneSelectorCallbackOK(List<VizSelectorOption> selected) {
    setState(() {
      currentZones = "";

      if (selected.length > 4) {
        currentZones = "4+";
      } else {
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

      if (selected.length > 4) {
        currentStatus = "4+";
      } else {
        selected.forEach((element) {
          currentStatus += element.description + " ";
        });
        currentStatus = currentStatus.trim();
      }
    });
  }

  void goToZonesSelector() {
    var selector = VizSelector(
        title: 'My Zones',
        multiple: true,
        onOKTapTapped: onZoneSelectorCallbackOK,
        options: availableZones);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => selector),
    );
  }

  void goToStatusSelector() {
    var selector = VizSelector(
        title: 'My Status',
        onOKTapTapped: onMyStatusSelectorCallbackOK,
        options: availableStatuses);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => selector),
    );
  }

  void goToSearchSelector() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VizSearch(title: 'Search...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    var leadingMenuButton = Expanded(
        child: VizElevated(
            title: 'Menu',
            onTap: goToMenu,
            textColor: const Color(0xFF159680)));

    var zonesWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('My Zones',
            style: const TextStyle(color: Colors.lightGreen, fontSize: 12.0)),
        Text(currentZones,
            style: const TextStyle(color: Colors.white, fontSize: 18.0),
            overflow: TextOverflow.ellipsis)
      ],
    );

    var statusWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('My Status',
            style: const TextStyle(color: Colors.lightGreen, fontSize: 12.0)),
        Text(currentStatus,
            style: const TextStyle(color: Colors.white, fontSize: 18.0),
            overflow: TextOverflow.ellipsis)
      ],
    );

    //ZONES AND STATUS
    var zonesWidgetBtn = Expanded(
        flex: 2,
        child:
            VizElevated(customWidget: zonesWidget, onTap: goToZonesSelector));
    var statusWidgetBtn = Expanded(
        flex: 2,
        child:
            VizElevated(customWidget: statusWidget, onTap: goToStatusSelector));

    //SEARCH
    var searchIcon = Icon(Icons.search, color: Colors.white);
    var searchIconWidget = Expanded(
        flex: 1,
        child:
            VizElevated(customWidget: searchIcon, onTap: goToSearchSelector));

    var centralWidgets = <Widget>[
      zonesWidgetBtn,
      Expanded(
          flex: 4,
          child: VizElevated(title: 'Jackpot', textColor: Colors.blue)),
      statusWidgetBtn,
      searchIconWidget
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(
          title: 'TechViz',
          leadingWidget: leadingMenuButton,
          centralWidgets: centralWidgets),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('home', style: const TextStyle(color: Colors.white)),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
