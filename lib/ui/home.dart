import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizSelector.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/userStatusRepository.dart';
import 'package:techviz/service/sectionService.dart';
import 'package:techviz/service/userService.dart';
import 'package:techviz/session.dart';
import 'package:techviz/ui/managerView.dart';
import 'package:techviz/ui/networkIndicator.dart';
import 'package:techviz/ui/sectionSelector.dart';
import 'package:techviz/ui/slotFloor.dart';
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

  List<String> currentSections = <String>[];
  UserStatus currentUserStatus;


  String get getSectionsText {
    String sections = "";
    if (currentSections.isEmpty) {
      sections = "-";
    }

    if (currentSections.length > 4) {
      sections = "4+";
    } else {
      currentSections.forEach((String section) {
        sections += section + " ";
      });
      sections = sections.trim();
    }
    return sections;
  }

  @override
  void initState(){
    super.initState();

    homeViewType = widget.homeViewType;
    scaffoldStateKey = GlobalKey();

    WidgetsBinding.instance.addObserver(this);
    setCurrentUserSections();
    setCurrentUserStatus(Session().user.userStatusID);

    loadView();

    UserService().userStatus.listen((int statusID){
      if(statusID == Session().user.userStatusID)
        return;

      Session().user.userStatusID = statusID;
      setCurrentUserStatus(statusID);

    });

    SectionService().userSectionsList.listen((List<String> sectionList){
      Function eq = const ListEquality<String>().equals;
      if(eq(sectionList, currentSections))
        return;

      Session().sections = sectionList;
      setCurrentUserSections();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void openDrawer() {
    scaffoldStateKey.currentState.openDrawer();
  }

  void setCurrentUserSections() {
    if(!mounted)
      return;

    setState(() {
      currentSections = Session().sections;
    });
  }

  void setCurrentUserStatus(int statusID) {
    if(!mounted)
      return;

    UserStatusRepository userStatusRepo = Repository().userStatusRepository;
    userStatusRepo.getStatuses().then((List<UserStatus> list) {
      setState(() {
        currentUserStatus = list.where((UserStatus status)=> status.id == statusID).first;
      });
    });
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

  void goToSectionSelector() {
    Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (context) =>  SectionSelector()),
    ).then((List<String> sections){

      if(sections==null)
        return;

      Session().sections = sections;
      setCurrentUserSections();
    });
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

        setState(() {
          currentUserStatus = userStatusSelected;
        });

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
    VizButton leadingMenuButton = VizButton(title: 'Menu', onTap: (){ openDrawer(); });

    String _statusText = currentUserStatus == null ? '-' : currentUserStatus.description;
    Color _statusTextColor = currentUserStatus == null || currentUserStatus.isOnline == false ? Colors.red : Colors.black;

    Column statusInnerWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('My Status', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
        Text(_statusText, style: TextStyle(color: _statusTextColor, fontSize: 16.0), overflow: TextOverflow.ellipsis)
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
    Spacer notificationWidgetBtn = Spacer(flex: 1);

    VizButton networkStatus = VizButton(customWidget: NetworkIndicator(), flex: 2);

    VizButton searchIconWidget = VizButton(customWidget: ImageIcon(AssetImage("assets/images/ic_search.png"), size: 30.0), onTap: goToSearchSelector, flex: 1);
    List<Widget> actionBarCentralWidgets = <Widget>[statusWidgetBtn, sectionsWidgetBtn, notificationWidgetBtn, networkStatus, searchIconWidget];

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
