import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/components/vizSummaryHeader.dart';
import 'package:techviz/presenter/managerViewListPresenter.dart';

import 'package:http/http.dart' as http;


class About extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AboutState();
}

class AboutState extends State<About> implements IListPresenter{

  //ManagerViewListPresenter _presenter;

  int _sortColumnIndex;
  bool _sortAscending = true;
  ResultsDataSource _resultsDataSource = ResultsDataSource([]);

  @override
  void initState() {
    super.initState();
//
//    _presenter = ManagerViewListPresenter(this);
//    _presenter.loadRows();
  }

  @override
  Widget build(BuildContext context) {

    Container container = Container(
      child: VizListView(),

      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF586676), Color(0xFF8B9EA7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.repeated)),
    );

    var safe = SafeArea(child: container, top: false, bottom: false);
    return Scaffold(backgroundColor: Colors.black, appBar: ActionBar(title: 'About'), body: safe);
  }

  @override
  void onLoadError(dynamic error) {
    // TODO: implement onLoadError
  }

  @override
  void onRowsLoaded(VizSummaryHeader summaryHeader) {
    // TODO: implement onRowsLoaded
  }
}



