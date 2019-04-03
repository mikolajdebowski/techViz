import 'package:techviz/components/vizSummaryHeader.dart';

abstract class IOpenTasksPresenter {
  void onOpenTasksLoaded(VizSummaryHeader summaryHeader);
  void onLoadError(dynamic error);
}

class OpenTasksPresenter{
  IOpenTasksPresenter _view;

  OpenTasksPresenter(this._view){
    assert(_view != null);
  }

  void loadOpenTasks(){


    Future.delayed(Duration(seconds: 1), (){
      List<VizSummaryHeaderEntry> entries = [
        VizSummaryHeaderEntry('Assigned', 12),
        VizSummaryHeaderEntry('Un-Assigned', 22),
        VizSummaryHeaderEntry('Overdue', 33),
        VizSummaryHeaderEntry('Escalated', 44)
      ];

      VizSummaryHeader header = VizSummaryHeader('Tasks', entries);

      _view.onOpenTasksLoaded(header);

    });


  }
}