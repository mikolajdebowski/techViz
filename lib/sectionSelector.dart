import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/presenter/sectionListPresenter.dart';
import 'package:techviz/repository/session.dart';

typedef fncOnTapOK();

class SectionSelector extends StatefulWidget {
  SectionSelector({Key key, @required this.onTapOK}) : super(key: key);
  final fncOnTapOK onTapOK;

  @override
  State<StatefulWidget> createState() => SectionSelectorState();
}

class SectionSelectorState extends State<SectionSelector>
    implements ISectionListPresenter<SectionModelPresenter> {
  List<SectionModelPresenter> sectionList = List<SectionModelPresenter>();
  SectionListPresenter sectionPresenter;

  @override
  void initState() {
    super.initState();

    sectionPresenter = SectionListPresenter(this);
  }

  void validate(BuildContext context) async {
//    if(selectedStatus == null)
//      return;
//
//    Session session = Session();
//    var toSend = {'userStatusID': selectedStatus.id, 'userID': session.user.UserID};
//
//    UserChannel userChannel = UserChannel();
//    await userChannel.submit(toSend);
//
    widget.onTapOK();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var defaultBgDeco = BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF636f7e), Color(0xFF9aa8b0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter));

    var okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => validate(context));

    var body = GridView.count(
        shrinkWrap: true,
        padding: EdgeInsets.all(4.0),
        childAspectRatio: 2.0,
        addAutomaticKeepAlives: false,
        crossAxisCount: 3,
        children: sectionList.map((SectionModelPresenter section) {
//        bool selected = selectedStatus!= null && selectedStatus.id.toString() ==  status.id;

          return VizOptionButton(section.sectionID,
              onTap: onOptionSelected, tag: section.sectionID, selected: section.selected);
        }).toList());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'My Sections', titleColor: Colors.blue, isRoot: true, tailWidget: okBtn),
      body: Container(
        decoration: defaultBgDeco,
        constraints: BoxConstraints.expand(),
        child: body,
      ),
    );
  }

  void onOptionSelected(Object tag) {
    setState(() {
//      selectedStatus = statusList.where((UserStatus s) => s.id == tag).first;
    });
  }

  @override
  void onLoadError(Error error) {
    // TODO: implement onLoadError
  }

  @override
  void onSectionListLoaded(List<SectionModelPresenter> result) {
    // TODO: implement onSectionListLoaded
    setState(() {
      sectionList = result;
    });

    Session session = Session();
    sectionPresenter.loadUserSections(session.user.UserID);
  }
}
