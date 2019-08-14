import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizSnackbar.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/statusListPresenter.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/session.dart';
import 'package:techviz/repository/userRepository.dart';
class StatusSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StatusSelectorState();
}

class StatusSelectorState extends State<StatusSelector> implements IStatusListPresenter<UserStatus> {
  List<UserStatus> statusList = <UserStatus>[];
  StatusListPresenter roleListPresenter;
  UserStatus selectedStatus;
  int _preSelectedID;

  @override
  void initState() {
    super.initState();

    _preSelectedID = Session().user.userStatusID;
    roleListPresenter = StatusListPresenter(this);
    roleListPresenter.loadUserStatus();
  }

  void validate(BuildContext buildContext) async {
    final VizSnackbar _snackbar = VizSnackbar.Processing('Sending request...');
    _snackbar.show(context);

    Session session = Session();
    UserRepository userRepository = Repository().userRepository;
    userRepository.update(session.user.userID, statusID: selectedStatus.id).then((int result) {
      _snackbar.dismiss();

      userRepository.getUser(session.user.userID).then((User user){
        Session().user = user;
        Navigator.of(context).pop<UserStatus>(selectedStatus);
      });
    }).catchError((dynamic error){
      _snackbar.dismiss();
      VizDialog.Alert(context, 'Error', error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: const [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));

    VizButton okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => validate(context));

    GridView body = GridView.count(
        shrinkWrap: true,
        padding: EdgeInsets.all(4.0),
        childAspectRatio: 2.0,
        addAutomaticKeepAlives: false,
        crossAxisCount: 3,
        children: statusList.map((UserStatus status) {
          bool selected = selectedStatus != null && selectedStatus.id.toString() == status.id;

          return VizOptionButton(status.description, onTap: onOptionSelected, tag: status.id, selected: selected);
        }).toList());

    Container container = Container(
      decoration: defaultBgDeco,
      constraints: BoxConstraints.expand(),
      child: body,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'My Status', titleColor: Colors.blue, tailWidget: okBtn),
      body: SafeArea(child: container),
    );
  }

  void onOptionSelected(Object tag) {
    setState(() {
      selectedStatus = statusList.where((UserStatus s) => s.id == tag).first;
    });
  }

  @override
  void onLoadError(dynamic error) {
    print(error);
  }

  @override
  void onStatusListLoaded(List<UserStatus> result) {
    setState(() {
      statusList = result;
      if (_preSelectedID == null) {
        selectedStatus = statusList.where((UserStatus us) => us.isOnline == false).first;
      } else {
        Iterable<UserStatus> where = statusList.where((UserStatus us) => us.id == _preSelectedID.toString());
        selectedStatus = where.first;
      }
    });
  }
}
