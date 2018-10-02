import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/statusListPresenter.dart';
import 'package:techviz/repository/rabbitmq/channel/userChannel.dart';
import 'package:techviz/repository/session.dart';

typedef fncOnTapOK(UserStatus selected);

class StatusSelector extends StatefulWidget {
  StatusSelector({Key key, @required this.onTapOK, this.preSelected}) : super(key: key);
  final fncOnTapOK onTapOK;
  final UserStatus preSelected;

  @override
  State<StatefulWidget> createState() => StatusSelectorState();
}

class StatusSelectorState extends State<StatusSelector> implements IStatusListPresenter<UserStatus> {
  List<UserStatus> statusList = List<UserStatus>();
  StatusListPresenter roleListPresenter;
  UserStatus selectedStatus;

  @override
  void initState(){
    super.initState();

    Session session = Session();
    roleListPresenter = StatusListPresenter(this);
    roleListPresenter.loadUserRoles(session.user.UserID);
  }

  void validate(BuildContext context) async {
    if(selectedStatus == null)
      return;

    Session session = Session();
    var toSend = {'userStatusID': selectedStatus.id, 'userID': session.user.UserID};

    UserChannel userChannel = UserChannel();
    userChannel.submit(toSend);

    widget.onTapOK(selectedStatus);

    Navigator.of(context).pop();
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
        bool selected = selectedStatus!= null && selectedStatus.id.toString() ==  status.id;

        return  VizOptionButton(
            status.description,
            onTap: onOptionSelected,
            tag: status.id,
            selected: selected);
     }).toList());


    var container = Container(
      decoration: defaultBgDeco,
      constraints: BoxConstraints.expand(),
      child: body,
    );


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'My Status', titleColor: Colors.blue, isRoot: false, tailWidget:okBtn),
      body: SafeArea(child: container, top: false, bottom: false),
    );
  }

  void onOptionSelected(Object tag){
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
      if(widget.preSelected==null){
        selectedStatus = statusList.where((UserStatus us) => us.isOnline == false).first;
      }
      else selectedStatus = widget.preSelected;
    });
  }
}
