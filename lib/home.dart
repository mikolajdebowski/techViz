import 'package:flutter/material.dart';
import 'package:techviz/adapters/machineAdapter.dart';
import 'package:techviz/attendant.home.dart';
import 'package:techviz/common/slideRightRoute.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizSearch.dart';
import 'package:techviz/components/vizSelector.dart';
import 'package:techviz/menu.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/sectionSelector.dart';
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

  @override
  void initState() {
    super.initState();
  }

  void goToMenu() {
    Navigator.push<Menu>(
      context,
      SlideRightRoute(widget: Menu()),
    );
  }

//  void onZoneSelectorCallbackOK(List<VizSelectorOption> selected) {
//    setState(() {
//      currentZones = "";
//
//      if (selected.length > 4) {
//        currentZones = "4+";
//      } else {
//        selected.forEach((element) {
//          currentZones += element.description + " ";
//        });
//        currentZones = currentZones.trim();
//      }
//    });
//  }

  void onSectionSelectorCallbackOK() {
    print('section selected callback');

  }

  void onMyStatusSelectorCallbackOK(UserStatus userStatusSelected) {
    setState(() {
      currentStatus = userStatusSelected;
      keyAttendant.currentState.onStatusChanged(currentStatus);
    });
  }

  void goToSectionSelector() {
    var selector = SectionSelector(
      onTapOK: onSectionSelectorCallbackOK,
    );

    Navigator.push<VizSelector>(
      context,
      MaterialPageRoute(builder: (context) => selector),
    );
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
      MaterialPageRoute(
          builder: (context) =>
              VizSearch<MachineModel>(domain: 'Machine, Players, etc', searchAdapter: new MachineAdapter())),
    );
  }

  @override
  Widget build(BuildContext context) {
    var leadingMenuButton = VizButton(title: 'Menu', onTap: goToMenu);

    //STATUS
    var statusText = currentStatus == null ? "OFF SHIFT" : currentStatus.description;
    var statusTextColor =
        currentStatus == null || currentStatus.isOnline == false ? Colors.red : Colors.black;

    var statusInnerWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('My Status', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
        Text(statusText,
            style: TextStyle(color: statusTextColor, fontSize: 16.0), overflow: TextOverflow.ellipsis)
      ],
    );

    var statusWidgetBtn = VizButton(customWidget: statusInnerWidget, flex: 3, onTap: goToStatusSelector);

    //ZONES
    var zonesInnerWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('My Sections', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
        Text(currentZones,
            style: TextStyle(color: Colors.black, fontSize: 16.0), overflow: TextOverflow.ellipsis)
      ],
    );

    var zonesWidgetBtn = VizButton(customWidget: zonesInnerWidget, flex: 3, onTap: goToSectionSelector);

    //NOTIFICATIONS
    var notificationInnerWidget = Column(
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
    );

    var notificationWidgetBtn = VizButton(customWidget: notificationInnerWidget, flex: 3);

    //SEARCH
    var searchIconWidget = VizButton(
        customWidget: ImageIcon(AssetImage("assets/images/ic_search.png"), size: 30.0),
        onTap: goToSearchSelector,
        flex: 1);

    //
    var actionBarCentralWidgets = <Widget>[
      statusWidgetBtn,
      zonesWidgetBtn,
      notificationWidgetBtn,
      searchIconWidget
    ];

    if (keyAttendant == null) {
      keyAttendant = GlobalKey<AttendantHomeState>();
    }
    var view = AttendantHome(keyAttendant);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(
          title: 'TechViz',
          leadingWidget: leadingMenuButton,
          centralWidgets: actionBarCentralWidgets,
          isRoot: true),
      body: view, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

abstract class HomeEvents {
  void onStatusChanged(UserStatus us);

  void onZoneChanged(Object obj);
}
