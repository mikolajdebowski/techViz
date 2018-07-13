import 'dart:async';

import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/home.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/iTaskRepository.dart';
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


      setState(() {
        statusMsg = 'Cleaning local database';
      });

      LocalRepository localRepo = LocalRepository();
      await localRepo.open();
      await localRepo.dropDatabase();

      setState(() {
        statusMsg = 'Loading Tasks!';
      });

      await Repository().taskRepository.fetch();


      setState(() {
        statusMsg = 'Loading Task Statuses!';
      });
      await Repository().taskStatusRepository.fetch();

      setState(() {
        statusMsg = 'Loading Task Types!';
      });
      await Repository().taskTypeRepository.fetch();


      setState(() {
        statusMsg = 'All good!';
      });


      Future.delayed(Duration(seconds: 2), () {
        Navigator.push<Home>(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
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
