import 'dart:async';

import 'package:flutter/material.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizSelector.dart';
import 'package:techviz/repository/userStatusRepository.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/ui/managerView.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/session.dart';
import 'package:techviz/repository/userSectionRepository.dart';
import 'package:techviz/ui/sectionSelector.dart';
import 'package:techviz/ui/slotFloor.dart';
import 'package:techviz/ui/statusSelector.dart';
import 'package:techviz/ui/taskView.dart';
import 'package:connectivity/connectivity.dart';

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

  StreamSubscription<MQTTConnectionStatus> vizStatus;
  StreamSubscription<ConnectivityResult> wifiStatus;
  Color networkIndicatorColor = Colors.green;
  String wifiStatusMsg = "No issues";  // wifi 'Not connected' or 'No issues'
  String serviceStatusMsg = "No issues";  // service 'Not connected' or 'No issues'
  bool isWifiActive = true;
  bool isServiceActive = true;
  bool isConnected = true;


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
  void initState(){
    super.initState();

    homeViewType = widget.homeViewType;
    scaffoldStateKey = GlobalKey();

    WidgetsBinding.instance.addObserver(this);
    loadDefaultSections();
    loadCurrentStatus();
    loadView();
    listenForWifiStatusChange();
    listenForMQTTStatusChange();
  }

  /*
    Color of button icon indicates network status:
    Red    - Not connected to the "Local wifi connection"
    Orange - No connection to "VizExplorer services connection"
    Green  - No issues
  */
  void listenForWifiStatusChange() {
    wifiStatus = Connectivity().onConnectivityChanged.listen((ConnectivityResult status) {
      print('wifi status changed to: ${status.toString()}');
      setState(() {
        if(status == ConnectivityResult.wifi){
          isWifiActive = true;
          wifiStatusMsg = "No issues";
          networkIndicatorColor = Colors.green;
        }else if(status == ConnectivityResult.none || status == ConnectivityResult.mobile){
          isWifiActive = false;
          wifiStatusMsg = "Not connected";
          networkIndicatorColor = Colors.red;
        }
      });
    });
  }

  void listenForMQTTStatusChange() {
    vizStatus = MQTTClientService().status.listen((MQTTConnectionStatus status) async{
//      print('MQTT service status changed to: ${status.toString()}');
      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
      if(connectivityResult == ConnectivityResult.wifi){
        setState(() {
          if(status == MQTTConnectionStatus.Connected){
            isServiceActive = true;
            serviceStatusMsg = "No issues";
            networkIndicatorColor = Colors.green;
          }else{
            isServiceActive = false;
            serviceStatusMsg = "Not connected";
            networkIndicatorColor = Colors.orange;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    wifiStatus.cancel();
    vizStatus.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void openDrawer() {
    scaffoldStateKey.currentState.openDrawer();
  }

  void _openNetworkDialog(){
    setState(() {
      String wifiTxt = "Local Wifi Connection: ";
      String serviceTxt = "VizExplorer Service Connection: ";

      showDialog<bool>(context: context, builder: (BuildContext context) {
        if(isWifiActive) {
          return AlertDialog(
            title: Text('Network Status'),
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(children: <Widget>[
                    Text(wifiTxt),
                    Text(
                      wifiStatusMsg,
                      style: TextStyle(
                          color: Colors.green),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Text(serviceTxt),
                    Text(
                      serviceStatusMsg,
                      style: TextStyle(
                          color: isServiceActive ? Colors.green : Colors.red),
                    ),
                  ]),
                ]),
            actions: <Widget>[
              FlatButton(
                child: Text("DONE"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        }else{
          return AlertDialog(
            title: Text('Network Status'),
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(children: <Widget>[
                    Text(wifiTxt),
                    Text(
                      wifiStatusMsg,
                      style: TextStyle(
                          color: Colors.red),
                    ),
                  ]),

                ]),
            actions: <Widget>[
              FlatButton(
                child: Text("DONE"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        }
      });
    });
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

  void loadCurrentStatus() {

    UserStatusRepository userStatusRepo = Repository().userStatusRepository;
    ISession session = Session();
    userStatusRepo.getStatuses().then((List<UserStatus> list) {
      setState(() {
        currentUserStatus = list.where((UserStatus status)=> status.id == session.user.userStatusID).first;
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

  //EVENTS
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

    Column networkStatusInnerWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Network', style: TextStyle(color: Color(0xFF566474), fontSize: 13.0)),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              color: networkIndicatorColor,
              shape: BoxShape.circle
          ),
        ),
      ],
    );

    VizButton networkStatus = VizButton(customWidget: networkStatusInnerWidget, flex: 2, onTap: (){ _openNetworkDialog();});

//    VizButton simulateMQTT = VizButton(title:'mqtt',flex: 2, onTap: () async{
//      if(isConnected){
//        isConnected = false;
//        MQTTClientService().disconnect();
//      }else{
//        isConnected = true;
//        await MQTTClientService().init('tvdev.internal.bis2.net', '4D8E280D-B840-4773-898D-0F9F71B82ACA', logging: false);
//        await MQTTClientService().connect();
//        listenForMQTTStatusChange();
//      }
//    },);

    VizButton searchIconWidget = VizButton(customWidget: ImageIcon(AssetImage("assets/images/ic_search.png"), size: 30.0), onTap: goToSearchSelector, flex: 1);
    List<Widget> actionBarCentralWidgets = <Widget>[statusWidgetBtn, sectionsWidgetBtn, notificationWidgetBtn, networkStatus, searchIconWidget];
//    List<Widget> actionBarCentralWidgets = <Widget>[statusWidgetBtn, sectionsWidgetBtn, notificationWidgetBtn, simulateMQTT, networkStatus, searchIconWidget];

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
