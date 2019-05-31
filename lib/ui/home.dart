import 'package:flutter/material.dart';
import 'package:techviz/ui/home.attendant.dart';
import 'package:techviz/common/slideRightRoute.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizSelector.dart';
import 'package:techviz/ui/home.manager.dart';
import 'package:techviz/ui/menu.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/session.dart';
import 'package:techviz/repository/userSectionRepository.dart';
import 'package:techviz/ui/sectionSelector.dart';
import 'package:techviz/ui/slotLookup.dart';
import 'package:techviz/ui/statusSelector.dart';


class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  GlobalKey<dynamic> homeChildKey;
  bool initialLoading = false;

  List<UserSection> currentSections = <UserSection>[];
  UserStatus currentUserStatus;

  String _userStatusText;
  bool _isOnline = false;

  String get getSectionsText {
    String sections = "";
    if (currentSections.isEmpty) {
      sections = "-";
    }

    if (currentSections.length > 4) {
      sections = "4+";
    } else {
      currentSections.forEach((UserSection section) {
        sections += section.sectionID + " ";
      });
      sections = sections.trim();
    }
    return sections;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadDefaultSections();

    ISession session = Session();
    if(session.role.isManager || session.role.isSupervisor){
      homeChildKey = GlobalKey<HomeManagerState>();
    }
    else if(session.role.isAttendant){
      homeChildKey = GlobalKey<HomeAttendantState>();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void goToMenu() {
    Navigator.push<Menu>(
      context,
      SlideRightRoute(widget: Menu()),
    );
  }

  void loadDefaultSections() {
    UserSectionRepository userSectionRepo = UserSectionRepository();
    ISession session = Session();
    userSectionRepo.getUserSection(session.user.userID).then((List<UserSection> list) {
      setState(() {
        currentSections = list;
      });
    });
  }

  void onUserSectionsChangedCallback(List<UserSection> sections) {
    print("onUserSectionsChangedCallback: ${sections.length.toString()}");
    setState(() {
      currentSections = sections;
    });
    homeChildKey.currentState.onUserSectionsChanged(currentSections);
  }

  void goToSectionSelector() {
    var selector = SectionSelector(onUserSectionsChanged: onUserSectionsChangedCallback);

    Navigator.push<VizSelector>(
      context,
      MaterialPageRoute(builder: (context) => selector),
    );
  }

  void goToStatusSelector() {
    StatusSelector selector = StatusSelector();
    Navigator.push<UserStatus>(
      context,
      MaterialPageRoute(builder: (context) => selector),
    ).then((UserStatus userStatusSelected){
      if(userStatusSelected!=null){
        if (userStatusSelected.isOnline) {
          Session().UpdateConnectionStatus(ConnectionStatus.Online);
        } else {
          Session().UpdateConnectionStatus(ConnectionStatus.Offline);
        }

        _userStatusText = userStatusSelected.description;
        _isOnline = userStatusSelected.isOnline;

        homeChildKey.currentState.onUserStatusChanged(userStatusSelected); // TODO(rmathias): NULL?
      }
    });
  }

  void goToSearchSelector() {
    Navigator.push<VizSelector>(
      context,
      MaterialPageRoute(builder: (context) => SlotFloor()),
    );
  }

  @override
  Widget build(BuildContext context) {
    VizButton leadingMenuButton = VizButton(title: 'Menu', onTap: goToMenu);

    String statusText = _userStatusText == null ? "OFF SHIFT" : _userStatusText;
    Color statusTextColor = _isOnline == false ? Colors.red : Colors.black;

    Column statusInnerWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('My Status', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
        Text(statusText, style: TextStyle(color: statusTextColor, fontSize: 16.0), overflow: TextOverflow.ellipsis)
      ],
    );

    VizButton statusWidgetBtn = VizButton(customWidget: statusInnerWidget, flex: 3, onTap: goToStatusSelector);

    //ZONES
    Column sectionsInnerWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('My Sections', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
        Text(getSectionsText, style: TextStyle(color: Colors.black, fontSize: 16.0), overflow: TextOverflow.ellipsis)
      ],
    );

    VizButton sectionsWidgetBtn = VizButton(customWidget: sectionsInnerWidget, flex: 3, onTap: goToSectionSelector);

    //NOTIFICATIONS
//    var notificationInnerWidget = Column(
//      crossAxisAlignment: CrossAxisAlignment.center,
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: <Widget>[
//        Text('Offline', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
//        Row(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text('7', style: TextStyle(color: Colors.black, fontSize: 18.0), overflow: TextOverflow.ellipsis),
//            ImageIcon(AssetImage("assets/images/ic_alert.png"), size: 15.0, color: Color(0xFFCD0000))
//          ],
//        )
//      ],
//    );

    //var notificationWidgetBtn = VizButton(customWidget: notificationInnerWidget, flex: 3);
    Spacer notificationWidgetBtn = Spacer(flex: 3);

    //SEARCH
    VizButton searchIconWidget = VizButton(customWidget: ImageIcon(AssetImage("assets/images/ic_search.png"), size: 30.0), onTap: goToSearchSelector, flex: 1);

    //
    List<Widget> actionBarCentralWidgets = <Widget>[statusWidgetBtn, sectionsWidgetBtn, notificationWidgetBtn, searchIconWidget];

    Widget view;

    Session session = Session();
    if(session.role.isManager || session.role.isSupervisor){
      view = HomeManager(homeChildKey);
    }
    else if(session.role.isAttendant){
      view = HomeAttendant(homeChildKey);
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'TechViz', leadingWidget: leadingMenuButton, centralWidgets: actionBarCentralWidgets),
      body: SafeArea(child: view), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


abstract class TechVizHome{
  void onUserStatusChanged(UserStatus us);
  void onUserSectionsChanged(Object obj);
}

