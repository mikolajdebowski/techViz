import 'package:techviz/model/section.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/sectionRepository.dart';
import 'package:techviz/service/sectionService.dart';

abstract class ISectionView {
  void onSectionListLoaded(List<SectionModelPresenter> result);
  void onLoadError(dynamic error);
}
abstract class ISectionPresenter{
  Future<List<String>> update({String userID, List<String> sections});
  void loadSections();
}

class SectionPresenter implements ISectionPresenter {
  ISectionView _view;
  SectionRepository _sectionRepository;
  ISectionService _sectionService;

  SectionPresenter(this._view) {
    _sectionRepository = Repository().sectionRepository;
    _sectionService = _sectionService ?? SectionService();
  }

  @override
  void loadSections() async {
    assert(_view != null);

    List<Section> sectionList = await _sectionRepository.getAll();
    List<SectionModelPresenter> list = <SectionModelPresenter>[];
    sectionList.forEach((Section section) {
      list.add(SectionModelPresenter(section.sectionID));
    });

    _view.onSectionListLoaded(list);
  }

  @override
  Future<List<String>> update({String userID, List<String> sections}){
    return _sectionService.update(userID, sections);
  }
}

class SectionModelPresenter {
  final String sectionID;
  bool selected;

  SectionModelPresenter(this.sectionID, {this.selected = false});
}
