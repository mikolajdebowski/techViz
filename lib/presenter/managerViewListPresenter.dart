import 'package:techviz/components/vizSummaryHeader.dart';

abstract class IListPresenter {
  void onRowsLoaded(VizSummaryHeader summaryHeader);
  void onLoadError(dynamic error);
}

class ManagerViewListPresenter{
  IListPresenter _view;

  ManagerViewListPresenter(this._view){
    assert(_view != null);
  }

  void loadRows(){
    Future.delayed(Duration(seconds: 2), (){
      List<VizSummaryHeaderEntry> entries = [
        VizSummaryHeaderEntry('Active Games', 1347),
        VizSummaryHeaderEntry('Head Count', 223),
        VizSummaryHeaderEntry('Reserved', 1),
        VizSummaryHeaderEntry('Out of Service', 2)
      ];

      VizSummaryHeader header = VizSummaryHeader('Slot Floor', entries);

      _view.onRowsLoaded(header);

    });


  }
}