import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskType.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class AttendantHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AttendantHomeState();
}

class AttendantHomeState extends State<AttendantHome> {
  String timeTakenStr = '00:00';

  void _onTapped() {
    var oneSec =  Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) {
      DateTime dt = DateFormat('mm:ss').parse(timeTakenStr);
      dt = dt.add(Duration(seconds: 1));
      setState(() {
        timeTakenStr = DateFormat('mm:ss').format(dt);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultHeaderDecoration = BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
        gradient: LinearGradient(
            colors: [ Color(0xFF4D4D4D),  Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.repeated));

    //LEFT PANEL WIDGETS
    //task list header and task list
    var listTasks = <Widget>[];
    List<Task> taskListData = kTask;

    for (var i = 1; i <= taskListData.length; i++) {
      Task task = taskListData[i - 1];
      var taskItem = GestureDetector(
          onTap: _onTapped,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [ Color(0xFF45505D),  Color(0xFF282B34)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          tileMode: TileMode.repeated)),
                  child: Center(child: Text(i.toString(), style: TextStyle(color: Colors.white))),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [ Color(0xFFB2C7CF),  Color(0xFFE4EDEF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          tileMode: TileMode.repeated)),
                  child: Center(
                      child: Text(
                    task.id,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),
                  )),
                ),
              ),
            ],
          ));

      listTasks.add(taskItem);
    }


    var taskTextStr = kTask.length == 0? 'No tasks' : (kTask.length==1 ? '1 Task' : '${kTask.length} Tasks');

    var leftPanel = Flexible(
      flex: 1,
      child: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints.expand(height: 80.0),
            decoration: defaultHeaderDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(taskTextStr, style: TextStyle(color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: ImageIcon( AssetImage("assets/images/ic_processing.png"), size: 15.0, color: Colors.blueGrey),
                      )

                    ],
                  ),
                ),
                Text('6 Pending', style: TextStyle(color: Colors.orange)),
                Text('Priority', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),

              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: listTasks,
            ),
          )
        ],
      ),
    );

    //CENTER PANEL WIDGETS
    var rowCenterHeader = Padding(
        padding: EdgeInsets.only(left: 10.0, top: 7.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Active Task', style: TextStyle(color: Colors.grey)),
                  Padding(
                      padding:  EdgeInsets.only(top: 5.0),
                      child: Text('01-01-21', style: TextStyle(color: Colors.lightBlue, fontSize: 18.0)))
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Task Type', style: TextStyle(color:  Color(0xFF8CAFB6))),
                  Padding(
                      padding:  EdgeInsets.only(top: 5.0),
                      child: Text('Jackpot', style: TextStyle(color: Colors.white, fontSize: 18.0)))
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Task Status', style: TextStyle(color: Colors.grey)),
                  Padding(
                      padding:  EdgeInsets.only(top: 5.0),
                      child: Text('Acknowledged',
                          style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)))
                ],
              ),
            ),
          ],
        ));

    var actionBoxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color:  Color(0xFFFFFFFF)),
        gradient: LinearGradient(
            colors: [ Color(0xFF81919D),  Color(0xFFAAB7BD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.repeated));

    var requiredAction = Padding(
        padding: EdgeInsets.all(5.0),
        child: Container(
            decoration: actionBoxDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ImageIcon( AssetImage("assets/images/ic_barcode.png"), size: 60.0, color: Colors.white),
                Center(
                    child: Text('Scan Machine',
                        style: TextStyle(
                            color:  Color(0xFFFFFFFF),
                            fontStyle: FontStyle.italic,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)))
              ],
            )));

    var taskInfo = Expanded(
        flex: 2,
        child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Container(
                constraints: BoxConstraints.tightFor(height: 60.0),
                decoration: actionBoxDecoration,
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text('Task Info',
                            style: TextStyle(
                              color:  Color(0xFF444444),
                              fontSize: 14.0,
                            ))),
                    Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text('\$1723.00',
                            style:
                                TextStyle(color:  Color(0xFFFFFFFF), fontSize: 20.0, fontWeight: FontWeight.bold)))
                  ],
                ))));

    var taskCustomer = Expanded(
        flex: 3,
        child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Container(
                constraints: BoxConstraints.tightFor(height: 60.0),
                decoration: actionBoxDecoration,
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text('Customer',
                            style: TextStyle(
                              color:  Color(0xFF444444),
                              fontSize: 14.0,
                            ))),
                    Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text('Mike Walker',
                            style:
                                TextStyle(color:  Color(0xFFFFFFFF), fontSize: 20.0, fontWeight: FontWeight.bold)))
                  ],
                ))));

    var taskBody = Padding(
      padding: EdgeInsets.only(left: 25.0, top: 5.0, right: 25.0, bottom: 5.0),
      child: Column(
        children: <Widget>[
          Row(
              children: <Widget>[taskInfo, taskCustomer],
            ),
          Flexible(
            child: requiredAction
          )
        ],
      ),
    );

    var centerPanel = Flexible(
      flex: 3,
      child: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints.expand(height: 80.0),
            decoration: defaultHeaderDecoration,
            child: rowCenterHeader,
          ),
          Expanded(
            child: taskBody
          )
        ],
      ),
    );

    //RIGHT PANEL WIDGETS
    var timerWidget = Padding(
      padding: EdgeInsets.only(top: 7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Time Taken', style: TextStyle(color: Colors.grey)),
          Text(timeTakenStr, style: TextStyle(color: Colors.teal, fontSize: 45.0, fontFamily: 'DigitalClock'))
        ],
      ),
    );

    var rightActionWidgets = Column(
      children: <Widget>[
        Expanded(
            child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [ Color(0xFFB2C7CF),  Color(0xFFE4EDEF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.repeated)),
              child: Center(
                  child: Text(
                'Complete',
                style: TextStyle(fontSize: 20.0),
              )),
            )),
            Container(
              width: 10.0,
              color:  Color(0xFF6EBD24),
            )
          ],
        )),
        Expanded(
            child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [ Color(0xFFB2C7CF), Color(0xFFE4EDEF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.repeated)),
              child: Center(child: Text('Cancel', style: TextStyle(fontSize: 20.0))),
            )),
            Container(
                width: 10.0,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [ Color(0xFFFF6600), Color(0xFFFFE100)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        tileMode: TileMode.repeated)))
          ],
        )),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [ Color(0xFFB2C7CF),  Color(0xFFE4EDEF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          tileMode: TileMode.repeated)),
                  child: Center(child: Text('Escalate', style: TextStyle(fontSize: 20.0))),
                ),
              ),
              Container(
                  width: 10.0,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [ Color(0xFF433177),  Color(0xFFF2003C)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          tileMode: TileMode.repeated)))
            ],
          ),
        ),
      ],
    );

    var rightPanel = Flexible(
      flex: 1,
      child: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints.expand(height: 80.0),
            decoration: defaultHeaderDecoration,
            child: timerWidget,
          ),
          Expanded(
            child: rightActionWidgets,
          )
        ],
      ),
    );

    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF586676), Color(0xFF8B9EA7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                tileMode: TileMode.repeated)),
        child: Row(
          children: <Widget>[leftPanel, centerPanel, rightPanel],
        ));
  }
}
