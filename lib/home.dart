import 'package:flutter/material.dart';
import 'package:techviz/adapters/machineAdapter.dart';
import 'package:techviz/components/vizSearch.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizSelector.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/menu.dart';
import 'package:techviz/helpers/slideRightRoute.dart';
import 'package:techviz/attendant.home.dart';

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
    Navigator.push<Menu>(
      context,
      SlideRightRoute(widget: Menu()),
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
        title: 'My Zones', multiple: true, onOKTapTapped: onZoneSelectorCallbackOK, options: availableZones);
    Navigator.push<VizSelector>(
      context,
      MaterialPageRoute(builder: (context) => selector),
    );
  }

  void goToStatusSelector() {
    var selector =
        VizSelector(title: 'My Status', onOKTapTapped: onMyStatusSelectorCallbackOK, options: availableStatuses);
    Navigator.push<VizSelector>(
      context,
      MaterialPageRoute(builder: (context) => selector),
    );
  }

  void goToSearchSelector() {
    Navigator.push<VizSelector>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              VizSearch<MachineModel>(domain: 'Machine, Players, etc', searchAdapter: new MachineAdapter())),
    );
  }

  @override
  Widget build(BuildContext context) {
    var leadingMenuButton = Expanded(child: VizElevated(title: 'Menu', onTap: goToMenu));

    //ZONES AND STATUS
    var zonesWidgetBtn = Expanded(
        flex: 3,
        child: VizElevated(
            customWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('My Zones', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
                Text(currentZones,
                    style: TextStyle(color: Colors.black, fontSize: 18.0), overflow: TextOverflow.ellipsis)
              ],
            ),
            onTap: goToZonesSelector));
    var statusWidgetBtn = Expanded(
        flex: 3,
        child: VizElevated(
            customWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('My Status', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
                Text(currentStatus,
                    style: TextStyle(color: Colors.black, fontSize: 18.0), overflow: TextOverflow.ellipsis)
              ],
            ),
            onTap: goToStatusSelector));

    var notificationWidgetBtn = Expanded(
        flex: 3,
        child: VizElevated(
            customWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Notifications', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('7', style: TextStyle(color: Colors.black, fontSize: 18.0), overflow: TextOverflow.ellipsis),
                ImageIcon(AssetImage("assets/images/ic_alert.png"), size: 15.0, color: Color(0xFFCD0000))
              ],
            )
          ],
        )));

    var searchIconWidget = Expanded(
        flex: 2,
        child: VizElevated(
            customWidget: ImageIcon(AssetImage("assets/images/ic_search.png"), size: 30.0), onTap: goToSearchSelector));

    var actionBarCentralWidgets = <Widget>[statusWidgetBtn, zonesWidgetBtn, notificationWidgetBtn, searchIconWidget];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'TechViz', leadingWidget: leadingMenuButton, centralWidgets: actionBarCentralWidgets),
      body: AttendantHome(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
