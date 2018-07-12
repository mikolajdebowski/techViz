import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techviz/home.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

void main() => runApp(TechVizApp());

class TechVizApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'TechViz',
      home: Home(),
    );
  }




  void loginProcess() {


    //get instance
    SessionClient client = SessionClient.getInstance();


    //init client
    client.init(ClientType.PROCESSOR, 'http://tvdev2.internal.bis2.net');


    //auth
    Future<String> authResponse = client.auth('irina', 'developeer');

    //request task data
    client.get('http://tvdev2.internal.bis2.net/rest/live/57bc13688a7-1613069bd49/57bc1368904-1613069bdb6/select.json');

    //logout
    client.abandon();


  }


}
