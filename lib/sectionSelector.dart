import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/presenter/sectionListPresenter.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/repository/userSectionRepository.dart';

typedef fncOnUserSectionsChanged(List<String> sections);

class SectionSelector extends StatefulWidget {
  SectionSelector({Key key, @required this.onUserSectionsChanged}) : super(key: key);
  final fncOnUserSectionsChanged onUserSectionsChanged;

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
    sectionPresenter.loadSections();
  }

  void onTap(BuildContext context) async {
    Session session = Session();
    List<String> sections = sectionList.where((SectionModelPresenter s) => s.selected).map((SectionModelPresenter s)=>s.sectionID).toList();

    UserSectionRepository repo = UserSectionRepository();
    repo.update(session.user.UserID, sections, callBack:updateCallback, updateRemote:true).then((dynamic d){
      updateCallback(sections);
      Navigator.of(context).pop();
    }).catchError((dynamic error){
      print(error);
    });

  }

  void updateCallback(List<String> sections) {
    widget.onUserSectionsChanged(sections);
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
      appBar: ActionBar(title: 'My Sections', titleColor: Colors.blue, isRoot: false, tailWidget: okBtn),
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

  void onUserSectionListLoaded(List<UserSection> userList) {
    setState(() {
      sectionList.forEach((SectionModelPresenter s) {
        userList.forEach((UserSection u){
          if(s.sectionID == u.SectionID){
            s.selected = true;
          }
        });
      });
    });
  }



  @override
  void onLoadError(Error error) {
    // TODO: implement onLoadError
  }

  @override
  void onSectionListLoaded(List<SectionModelPresenter> result) {
    setState(() {
      sectionList = result;
    });

    Session session = Session();
    sectionPresenter.loadUserSections(session.user.UserID);

  }
}
