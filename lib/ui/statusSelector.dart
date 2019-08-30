import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizSnackbar.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/statusPresenter.dart';
import 'package:techviz/session.dart';
class StatusSelector extends StatefulWidget {
  final IStatusPresenter statusPresenter;

  const StatusSelector({this.statusPresenter});

  @override
  State<StatefulWidget> createState() => StatusSelectorState();
}

class StatusSelectorState extends State<StatusSelector> implements IStatusView {
  List<UserStatus> _statusList = <UserStatus>[];
  IStatusPresenter _statusPresenter;
  UserStatus _selectedStatus;
  int _preSelectedID;

  @override
  void initState() {
    super.initState();

    _preSelectedID = Session().user.userStatusID;
    _statusPresenter = widget.statusPresenter ?? StatusPresenter(this);
    _statusPresenter.loadUserStatus();
  }

  void update(BuildContext buildContext) async {
    final VizSnackbar _snackbar = VizSnackbar.Processing('Updating...');
    _snackbar.show(context);

    Session session = Session();

    _statusPresenter.update(session.user.userID, statusID: _selectedStatus.id).then((dynamic d){
      _snackbar.dismiss();
      Session().user.userStatusID = _selectedStatus.id;
      Navigator.of(buildContext).pop(_selectedStatus);
    }).catchError((dynamic error){
      _snackbar.dismiss();
      VizDialog.Alert(context, 'Error', error.toString());
    });


//ACT-1555
//    UserRepository userRepository = Repository().userRepository;
//    userRepository.update(session.user.userID, statusID: selectedStatus.id).then((int result) {
//      _snackbar.dismiss();
//
//      userRepository.getUser(session.user.userID).then((User user){
//        Session().user = user;
//        Navigator.of(context).pop<UserStatus>(selectedStatus);
//      });
//    }).catchError((dynamic error){
//      _snackbar.dismiss();
//      VizDialog.Alert(context, 'Error', error.toString());
//    });

  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: const [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));

    VizButton okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => update(context));

    GridView body = GridView.count(
        shrinkWrap: true,
        padding: EdgeInsets.all(4.0),
        childAspectRatio: 2.0,
        addAutomaticKeepAlives: false,
        crossAxisCount: 3,
        children: _statusList.map((UserStatus status) {
          bool selected = _selectedStatus != null && _selectedStatus.id == status.id;

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
      _selectedStatus = _statusList.where((UserStatus s) => s.id == tag).first;
    });
  }

  @override
  void onLoadError(dynamic error) {
    print(error);
  }

  @override
  void onStatusListLoaded(List<UserStatus> result) {
    setState(() {
      _statusList = result;
      if (_preSelectedID == null) {
        _selectedStatus = _statusList.where((UserStatus us) => us.isOnline == false).first;
      } else {
        Iterable<UserStatus> where = _statusList.where((UserStatus us) => us.id == _preSelectedID);
        _selectedStatus = where.first;
      }
    });
  }
}
