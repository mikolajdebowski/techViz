import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/components/vizSummaryHeader.dart';

import 'package:http/http.dart' as http;


class About extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AboutState();
}

class AboutState extends State<About> {

  @override
  void initState() {
    super.initState();
  }

  void callbackLeft(dynamic obj){
    print(obj);

  }

  void callbackRight(dynamic obj){
    print(obj);
  }

  @override
  Widget build(BuildContext context) {

//    List<RowObject> data = <RowObject>[
//      RowObject(location: "01-01-01", type:"Printer", status: "Assigned", user: "Joe", time: "1:03"),
//      RowObject(location: "01-01-02", type:"Change", status: "Carded", user: "Amy", time: "2:32"),
//      RowObject(location: "02-01-04", type:"Tilt", status: "Acknowledged", user: "Bob", time: "0:45"),
//      RowObject(location: "03-08-12", type:"Jackpot", status: "Jackpot", user: "Susan", time: "12:18"),
//      RowObject(location: "G-01-05", type:"Verify", status: "Carded", user: "James", time: "3:15"),
//      RowObject(location: "D-04-08", type:"Change", status: "Acknowledged", user: "Michelle", time: "0:28"),
//      RowObject(location: "05-01-01", type:"Bill", status: "Carded", user: "Joe", time: "4:55"),
//      RowObject(location: "01-01-01", type:"Printer", status: "Assigned", user: "Joe", time: "1:03"),
//      RowObject(location: "01-01-02", type:"Change", status: "Carded", user: "Amy", time: "2:32"),
//      RowObject(location: "02-01-04", type:"Tilt", status: "Acknowledged", user: "Bob", time: "0:45"),
//      RowObject(location: "03-08-12", type:"Jackpot", status: "Jackpot", user: "Susan", time: "12:18"),
//      RowObject(location: "G-01-05", type:"Verify", status: "Carded", user: "James", time: "3:15"),
//      RowObject(location: "D-04-08", type:"Change", status: "Acknowledged", user: "Michelle", time: "0:28"),
//      RowObject(location: "05-01-01", type:"Bill", status: "Carded", user: "Joe", time: "4:55"),
//      RowObject(location: "01-01-01", type:"Printer", status: "Assigned", user: "Joe", time: "1:03"),
//      RowObject(location: "01-01-02", type:"Change", status: "Carded", user: "Amy", time: "2:32"),
//      RowObject(location: "02-01-04", type:"Tilt", status: "Acknowledged", user: "Bob", time: "0:45"),
//      RowObject(location: "03-08-12", type:"Jackpot", status: "Jackpot", user: "Susan", time: "12:18"),
//      RowObject(location: "G-01-05", type:"Verify", status: "Carded", user: "James", time: "3:15"),
//      RowObject(location: "D-04-08", type:"Change", status: "Acknowledged", user: "Michelle", time: "0:28"),
//      RowObject(location: "05-01-01", type:"Bill", status: "Carded", user: "Joe", time: "4:55"),
//      RowObject(location: "01-01-01", type:"Printer", status: "Assigned", user: "Joe", time: "1:03"),
//      RowObject(location: "01-01-02", type:"Change", status: "Carded", user: "Amy", time: "2:32"),
//      RowObject(location: "02-01-04", type:"Tilt", status: "Acknowledged", user: "Bob", time: "0:45"),
//      RowObject(location: "03-08-12", type:"Jackpot", status: "Jackpot", user: "Susan", time: "12:18"),
//      RowObject(location: "G-01-05", type:"Verify", status: "Carded", user: "James", time: "3:15"),
//      RowObject(location: "D-04-08", type:"Change", status: "Acknowledged", user: "Michelle", time: "0:28"),
//      RowObject(location: "05-01-01", type:"Bill", status: "Carded", user: "Joe", time: "4:55"),
//    ];


    SwipeAction toTheLeftAction = SwipeAction('To the left', (dynamic whatever){
      print(whatever);
    });

    SwipeAction toTheRightAction = SwipeAction('To the right', (dynamic whatever){
      print(whatever);
    });

    Container container = Container(
      child: VizListView(/*data: data,*/ callbackLeft: toTheLeftAction, callbackRight: toTheRightAction),

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

}



