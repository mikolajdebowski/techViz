import 'package:techviz/model/section.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/sectionRepository.dart';
import 'package:techviz/repository/userSectionRepository.dart';

abstract class ISectionListPresenter<SectionModelPresenter> {
  void onSectionListLoaded(List<SectionModelPresenter> result);
  void onUserSectionListLoaded(List<UserSection> result);

  void onLoadError(Error error);
}


class SectionListPresenter {
  ISectionListPresenter<SectionModelPresenter> _view;
  SectionRepository _sectionRepository;
  UserSectionRepository _userSectionRepository;

  SectionListPresenter(this._view) {
    _sectionRepository = Repository().sectionRepository;
    _userSectionRepository = Repository().userSectionRepository;
  }

  void loadSections() async {
    assert(_view != null);

    List<Section> sectionList = await _sectionRepository.getAll();
    List<SectionModelPresenter> list = List<SectionModelPresenter>();
    sectionList.forEach((Section section) {
      list.add(SectionModelPresenter(section.SectionID));
    });

    _view.onSectionListLoaded(list);
  }

  void loadUserSections(String userID) async{
    assert(_view != null);

    List<UserSection> userSectionList = await _userSectionRepository.getUserSection(userID);
    _view.onUserSectionListLoaded(userSectionList);
  }
}



class SectionModelPresenter {
  final String sectionID;
  bool selected;

  SectionModelPresenter(this.sectionID, {this.selected = false});
}
