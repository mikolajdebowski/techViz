import 'dart:async';

import 'package:flutter/material.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/repository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class Loader extends StatefulWidget {
  Loader({Key key}) : super(key: key);

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  String statusMsg = '';
  bool processing = true;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void authErrorHandler(AuthError err) {}

  void loadData() async {



    try{
      Repository repo = Repository();
      await repo.configure(Flavor.PROCESSOR);

      setState(() {
        statusMsg = 'Cleaning local database...';
      });

      LocalRepository localRepo = LocalRepository();
      await localRepo.open();
      await localRepo.dropDatabase();

      setState(() {
        statusMsg = 'Loading Tasks...';
      });

      await repo.taskRepository.fetch();

      setState(() {
        statusMsg = 'Loading Task Statuses...';
      });
      await repo.taskStatusRepository.fetch();

      setState(() {
        statusMsg = 'Loading Task Types...';
      });
      await repo.taskTypeRepository.fetch();

      setState(() {
        statusMsg = 'All good!';
      });

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
    catch(e){
      print(e.toString());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];

    if (processing) children.add(CircularProgressIndicator());

    children.add(Flexible(
        child: Padding(
            padding: EdgeInsets.only(left: 10.0),
            child:
                Text(statusMsg, overflow: TextOverflow.fade, style: TextStyle(color: Colors.white), softWrap: false))));

    return Scaffold(
        backgroundColor: Colors.black, body: Center(child: Row(mainAxisSize: MainAxisSize.min, children: children)));
  }
}
