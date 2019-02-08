import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/statusListPresenter.dart';
import 'package:techviz/repository/async/UserRouting.dart';
import 'package:techviz/repository/local/userTable.dart';
import 'package:techviz/repository/session.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';
import 'package:flushbar/flushbar.dart';

typedef fncOnTapOK(UserStatus selected);

class StatusSelector extends StatefulWidget {
  StatusSelector({Key key, @required this.onTapOK, this.preSelectedID}) : super(key: key) {
    //print('preSelectedID: ${this.preSelectedID}');
  }
  final fncOnTapOK onTapOK;
  final int preSelectedID;

  @override
  State<StatefulWidget> createState() => StatusSelectorState();
}

class StatusSelectorState extends State<StatusSelector> implements IStatusListPresenter<UserStatus> {
  List<UserStatus> statusList = List<UserStatus>();
  StatusListPresenter roleListPresenter;
  UserStatus selectedStatus;
  Flushbar _loadingBar;


  @override
  void initState() {
    super.initState();

    Session session = Session();
    roleListPresenter = StatusListPresenter(this);
    roleListPresenter.loadUserRoles(session.user.UserID);

    _loadingBar = VizDialog.LoadingBar(message: 'Sending request...');
  }

  void validate(BuildContext context) async {
    print(_loadingBar.isShowing());
    if (_loadingBar.isShowing()) return;

    _loadingBar.show(context);

    DeviceInfo deviceInfo = await Utils.deviceInfo;
    var toSend = {'userStatusID': selectedStatus.id, 'userID': Session().user.UserID, 'deviceID': deviceInfo.DeviceID};

    UserRouting().PublishMessage(toSend).then((dynamic result){
      _loadingBar.dismiss();

      User returnedUser = result as User;
      UserTable.updateStatusID(returnedUser.UserID, returnedUser.UserStatusID.toString()).then((User user) {
        Session().user = user;
        widget.onTapOK(selectedStatus);
        Navigator.of(context).pop();
      });

    }).catchError((dynamic error){
      _loadingBar.dismiss();
      VizDialog.Alert(context, 'Error', error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));

    var okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => validate(context));

    var body = GridView.count(
        shrinkWrap: true,
        padding: EdgeInsets.all(4.0),
        childAspectRatio: 2.0,
        addAutomaticKeepAlives: false,
        crossAxisCount: 3,
        children: statusList.map((UserStatus status) {
          bool selected = selectedStatus != null && selectedStatus.id.toString() == status.id;

          return VizOptionButton(status.description, onTap: onOptionSelected, tag: status.id, selected: selected);
        }).toList());

    var container = Container(
      decoration: defaultBgDeco,
      constraints: BoxConstraints.expand(),
      child: body,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'My Status', titleColor: Colors.blue, isRoot: false, tailWidget: okBtn),
      body: SafeArea(child: container),
    );
  }

  void onOptionSelected(Object tag) {
    setState(() {
      selectedStatus = statusList.where((UserStatus s) => s.id == tag).first;
    });
  }

  @override
  void onLoadError(Error error) {
    // TODO: implement onLoadError
  }

  @override
  void onStatusListLoaded(List<UserStatus> result) {
    setState(() {
      statusList = result;
      if (widget.preSelectedID == null) {
        selectedStatus = statusList.where((UserStatus us) => us.isOnline == false).first;
      } else {
        selectedStatus = statusList.where((UserStatus us) => us.id == widget.preSelectedID.toString()).first;
      }
    });
  }
}
