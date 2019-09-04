import 'package:flutter/material.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizSnackbar.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/presenter/sectionPresenter.dart';
import 'package:techviz/session.dart';

typedef FncOnUserSectionsChanged = void Function(List<UserSection> sections);

class SectionSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SectionSelectorState();
}

class SectionSelectorState extends State<SectionSelector> implements ISectionView {
  List<SectionModelPresenter> sectionList = <SectionModelPresenter>[];
  SectionPresenter sectionPresenter;

  @override
  void initState() {
    super.initState();

    sectionPresenter = SectionPresenter(this);
    sectionPresenter.loadSections();
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration defaultBgDeco = BoxDecoration(
        gradient: LinearGradient(
            colors: const [Color(0xFF636f7e), Color(0xFF9aa8b0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter));

    VizButton okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => onTap(context));

    List<Widget> actions = <Widget>[];
    actions.add(VizButton(title: 'All', onTap: onSelectAllTapped));
    actions.add(VizButton(title: 'None', onTap: onSelectNoneTapped));

    GridView body = GridView.count(
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


    Container container = Container(
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
  void onLoadError(dynamic error) {
    print(error);
  }

  @override
  void onSectionListLoaded(List<SectionModelPresenter> result) {
    setState(() {
      sectionList = result;

      sectionList.forEach((SectionModelPresenter smp){
        smp.selected = Session().sections.contains(smp.sectionID);
      });

    });
  }

  void onTap(BuildContext context){
    final VizSnackbar _snackbar = VizSnackbar.Processing('Sending request...');
    _snackbar.show(context);

    Session session = Session();
    List<String> sections = sectionList.where((SectionModelPresenter s) => s.selected).map((SectionModelPresenter s)=>s.sectionID).toList();

    DeviceInfo info = DeviceUtils().deviceInfo;

    sectionPresenter.update(userID: session.user.userID, sections: sections, deviceID: info.DeviceID).then((dynamic d){
      _snackbar.dismiss();
      Navigator.of(context).pop(sections);
    }).catchError((dynamic error){
      _snackbar.dismiss();
      VizDialog.Alert(context, 'Error', error.toString());
    });
  }
}
