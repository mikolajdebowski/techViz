import 'package:flutter/material.dart';
import 'package:techviz/adapters/machineAdapter.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizSearch.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizSelector.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/menu.dart';
import 'package:techviz/common/slideRightRoute.dart';
import 'package:techviz/attendant.home.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/statusSelector.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  GlobalKey<AttendantHomeState> keyAttendant;
  bool initialLoading = false;

  String currentZones = '-';
  UserStatus currentStatus;
  List<VizSelectorOption> availableZones = List<VizSelectorOption>();

  @override
  void initState() {
    super.initState();

    //TODO: IMPLEMENT ZONE
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

  void onMyStatusSelectorCallbackOK(UserStatus userStatusSelected) {
    setState(() {
      currentStatus = userStatusSelected;
      keyAttendant.currentState.onStatusChanged(currentStatus);
    });
  }

  void goToZonesSelector() {
//    var selector = VizSelector(
//        'My Zones', availableZones, multiple: true, onOKTapTapped: onZoneSelectorCallbackOK);
//    Navigator.push<VizSelector>(
//      context,
//      MaterialPageRoute(builder: (context) => selector),
//    );
  }

  void goToStatusSelector() {
    var selector = StatusSelector(onTapOK: onMyStatusSelectorCallbackOK, preSelected: currentStatus);
    Navigator.push<VizSelector>(
      context,
      MaterialPageRoute(builder: (context) => selector),
    );
  }

  void goToSearchSelector() {
    Navigator.push<VizSelector>(
      context,
      MaterialPageRoute(builder: (context) => VizSearch<MachineModel>(domain: 'Machine, Players, etc', searchAdapter: new MachineAdapter())),
    );
  }

  @override
  Widget build(BuildContext context) {
    var leadingMenuButton = VizButton('Menu', onTap: goToMenu);

    var statusText = currentStatus == null ? "OFF SHIFT": currentStatus.description;
    var statusTextColor = currentStatus == null || currentStatus.isOnline == false ? Colors.red : Colors.black;

    var statusWidgetText = Text(statusText, style: TextStyle(color: statusTextColor, fontSize: 16.0), overflow: TextOverflow.ellipsis);

    //ZONES AND STATUSES
    var statusWidgetBtn = Expanded(
        flex: 3,
        child: VizElevated(
            customWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('My Status', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
                statusWidgetText],
            ),
            onTap: goToStatusSelector));



    var zonesWidgetBtn = Expanded(
        flex: 3,
        child: VizElevated(
            customWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('My Zones', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
                Text(currentZones, style: TextStyle(color: Colors.black, fontSize: 16.0), overflow: TextOverflow.ellipsis)
              ],
            ),
            onTap: goToZonesSelector));


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

    var searchIconWidget = Expanded(flex: 2, child: VizElevated(customWidget: ImageIcon(AssetImage("assets/images/ic_search.png"), size: 30.0), onTap: goToSearchSelector));

    var actionBarCentralWidgets = <Widget>[statusWidgetBtn, zonesWidgetBtn, notificationWidgetBtn, searchIconWidget];

    if(keyAttendant==null){
      keyAttendant = GlobalKey<AttendantHomeState>();
    }
    var view = AttendantHome(keyAttendant);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'TechViz', leadingWidget: leadingMenuButton, centralWidgets: actionBarCentralWidgets, isRoot: true),
      body: view, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


abstract class HomeEvents{
  void onStatusChanged(UserStatus us);
  void onZoneChanged(Object obj);
}