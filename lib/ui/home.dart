import 'package:flutter/material.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizSelector.dart';
import 'package:techviz/ui/managerView.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/session.dart';
import 'package:techviz/repository/userSectionRepository.dart';
import 'package:techviz/ui/sectionSelector.dart';
import 'package:techviz/ui/slotLookup.dart';
import 'package:techviz/ui/statusSelector.dart';
import 'package:techviz/ui/taskView.dart';

import 'drawer.dart';

enum HomeViewType{
  TaskView,ManagerView
}

class Home extends StatefulWidget {
  final HomeViewType homeViewType;
  const Home(this.homeViewType);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  HomeViewType homeViewType;
  GlobalKey<ScaffoldState> scaffoldStateKey;
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

    homeViewType = widget.homeViewType;
    scaffoldStateKey = GlobalKey();

    WidgetsBinding.instance.addObserver(this);
    loadDefaultSections();
    loadView();
  }

  void loadView() {
    assert(homeViewType!=null);
    if(homeViewType == HomeViewType.ManagerView){
      homeChildKey = GlobalKey<ManagerViewState>();
    }else if(homeViewType == HomeViewType.TaskView){
      homeChildKey = GlobalKey<TaskViewState>();
    }
    assert(homeChildKey!=null);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void goToMenu() {
    scaffoldStateKey.currentState.openDrawer();
  }

  void loadDefaultSections() {
    UserSectionRepository userSectionRepo = Repository().userSectionRepository;
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
    SectionSelector selector = SectionSelector(onUserSectionsChanged: onUserSectionsChangedCallback);

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
    ).then((UserStatus userStatusSelected) {
      if (userStatusSelected != null) {
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
    VizButton leadingMenuButton = VizButton(title: 'Menu', onTap: (){ goToMenu(); });

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

    Spacer notificationWidgetBtn = Spacer(flex: 3);
    VizButton searchIconWidget = VizButton(customWidget: ImageIcon(AssetImage("assets/images/ic_search.png"), size: 30.0), onTap: goToSearchSelector, flex: 1);
    List<Widget> actionBarCentralWidgets = <Widget>[statusWidgetBtn, sectionsWidgetBtn, notificationWidgetBtn, searchIconWidget];

    return Scaffold(
      key: scaffoldStateKey,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'TechViz', leadingWidget: leadingMenuButton, centralWidgets: actionBarCentralWidgets),
      body: SafeArea(child: bodyWidget),
      drawer: SafeArea(child: MenuDrawer(homeChildKey)),
    );
  }

  Widget get bodyWidget{
    return homeChildKey is LabeledGlobalKey<ManagerViewState> ? ManagerView(homeChildKey) : TaskView(homeChildKey);
  }
}

abstract class TechVizHome {
  void onUserStatusChanged(UserStatus us);
  void onUserSectionsChanged(List<UserSection> sections);
}
