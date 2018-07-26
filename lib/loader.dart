import 'dart:async';

import 'package:flutter/material.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/repository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class Loader extends StatefulWidget {
  Loader({Key key}) : super(key: key);

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {

  String statusMsg = '';

  @override
  void initState(){
    // TODO: implement initState

    SessionClient client = SessionClient.getInstance();
    client.init(ClientType.PROCESSOR, 'http://tvdev2.internal.bis2.net');
    setState(() {
      statusMsg = 'Authenticating';
    });

    Future<String> authResponse = client.auth('irina', 'developer');
    authResponse.then((String response) async {

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
    });

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              CircularProgressIndicator(),
              Padding(padding: EdgeInsets.only(left: 10.0), child: Text(statusMsg, style: TextStyle(color: Colors.white)))
        ]
      )
    )
    );
  }

}
