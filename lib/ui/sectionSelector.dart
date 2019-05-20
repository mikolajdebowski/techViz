import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/model/section.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/presenter/sectionListPresenter.dart';
import 'package:techviz/repository/async/SectionRouting.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/repository/userSectionRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

typedef void FncOnUserSectionsChanged(List<UserSection> sections);

class SectionSelector extends StatefulWidget {
  SectionSelector({Key key, @required this.onUserSectionsChanged}) : super(key: key);
  final FncOnUserSectionsChanged onUserSectionsChanged;

  @override
  State<StatefulWidget> createState() => SectionSelectorState();
}

class SectionSelectorState extends State<SectionSelector>
    implements ISectionListPresenter<SectionModelPresenter> {
  List<SectionModelPresenter> sectionList = List<SectionModelPresenter>();
  SectionListPresenter sectionPresenter;
  Flushbar _loadingBar;

  @override
  void initState() {
    super.initState();

    sectionPresenter = SectionListPresenter(this);
    sectionPresenter.loadSections();

    _loadingBar = VizDialog.LoadingBar(message: 'Sending request...');
  }

  void onTap(BuildContext context) async {
    if (_loadingBar.isShowing())
      return;

    _loadingBar.show(context);

    Session session = Session();
    List<String> sections = sectionList.where((SectionModelPresenter s) => s.selected).map((SectionModelPresenter s)=>s.sectionID).toList();

    DeviceInfo info = await Utils.deviceInfo;
    var toSubmit = {'userID': session.user.userID, 'sections': sections, 'deviceID': info.DeviceID};

    SectionRouting().PublishMessage(toSubmit).then<List<Section>>((dynamic list) async{
      _loadingBar.dismiss();

      var toUpdateLocally = (list as List<Section>);

      await UserSectionRepository().update(session.user.userID, toUpdateLocally.map((Section s) => s.sectionID).toList());

      print('');
      UserSectionRepository().getUserSection(session.user.userID).then((List<UserSection> sectionToMain){
        backToMain(sectionToMain);
      });

    }).catchError((dynamic error){
      _loadingBar.dismiss();
      VizDialog.Alert(context, 'Error', error.toString());
    });
  }

  void backToMain(List<UserSection> sections){
    widget.onUserSectionsChanged(sections);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var defaultBgDeco = BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF636f7e), Color(0xFF9aa8b0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter));

    var okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => onTap(context));

    var actions = <Widget>[];
    actions.add(VizButton(title: 'All', onTap: onSelectAllTapped));
    actions.add(VizButton(title: 'None', onTap: onSelectNoneTapped));

    var body = GridView.count(
        shrinkWrap: true,
        padding: EdgeInsets.all(4.0),
        childAspectRatio: 1.0,
        addAutomaticKeepAlives: false,
        crossAxisCount: 8,
        children: sectionList.map((SectionModelPresenter section) {
//        bool selected = selectedStatus!= null && selectedStatus.id.toString() ==  status.id;

          return VizOptionButton(section.sectionID,
              onTap: onOptionSelected, tag: section.sectionID, selected: section.selected);
        }).toList());


    var container = Container(
      decoration: defaultBgDeco,
      constraints: BoxConstraints.expand(),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 60.0,
            child: Row(children: actions),
          ),
          Expanded(
            child: body,
          )
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'My Sections', titleColor: Colors.blue, tailWidget: okBtn),
      body: SafeArea(child: container)
    );
  }

  void onOptionSelected(Object tag) {
    setState(() {
      sectionList.forEach((SectionModelPresenter s) {
          if(s.sectionID == tag){
            if(s.selected){
              s.selected = false;
            }else {
              s.selected = true;
            }
          }
      });
    });
  }

  void onSelectAllTapped() {
    setState(() {
      sectionList.forEach((SectionModelPresenter s) {
        s.selected = true;
      });
    });
  }

  void onSelectNoneTapped() {
    setState(() {
      sectionList.forEach((SectionModelPresenter s) {
        s.selected = false;
      });
    });
  }

  @override
  void onUserSectionListLoaded(List<UserSection> userList) {
    setState(() {
      sectionList.forEach((SectionModelPresenter s) {
        userList.forEach((UserSection u){
          if(s.sectionID == u.sectionID){
            s.selected = true;
          }
        });
      });
    });
  }

  @override
  void onLoadError(dynamic error) {
    print(error);
  }

  @override
  void onSectionListLoaded(List<SectionModelPresenter> result) {
    setState(() {
      sectionList = result;
    });

    Session session = Session();
    sectionPresenter.loadUserSections(session.user.userID);
  }
}
