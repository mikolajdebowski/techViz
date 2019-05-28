
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class Logging extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoggingState();
}

class LoggingState extends State<Logging> {

  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();

    loadLogs();

    super.initState();
  }

  void loadLogs(){
    Utils.readLog().then((String logs){
      _controller.text = logs;
    });
  }

  void onBackPressed(){
    var nav = Navigator.of(context);
    if(nav.canPop()){
      nav.pop();
    }
  }

  void onCopyPressed(){
    Fluttertoast.showToast( msg: "Log copied");
    Clipboard.setData(ClipboardData(text: _controller.text));
  }

  void onClearPressed(){
    Fluttertoast.showToast( msg: "Log cleared");
    Utils.clearLog().then((bool cleared){
      loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    var header = Stack(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(left: 5.0, top: 5.0), child: RaisedButton(child: Text('Back', style: TextStyle(color: Colors.black)), onPressed: onBackPressed)),
        Padding(padding: EdgeInsets.only(top: 10.0), child: Align(
            alignment: Alignment.topCenter,
            child: Text('Logging view', style: TextStyle(color: Colors.white))
        ))
      ]
    );

    var loggingList = Expanded(child: TextField(
      style: TextStyle(color: Colors.white70),
      maxLines: null,
      controller: _controller,
      keyboardType: TextInputType.multiline,
    ));

    var headerAndLoggingList = Column(children: <Widget>[
      header,loggingList
    ]);


    var btnRightBtns = Align(alignment: Alignment.bottomRight, child: Row(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[
      Padding(padding: EdgeInsets.only(right: 10.0),child: RaisedButton(child: Text('Clear logs', style: TextStyle(color: Colors.black)), onPressed: onClearPressed)),
        Padding(padding: EdgeInsets.only(right: 10.0),child: RaisedButton(child: Text('Copy to clipboard', style: TextStyle(color: Colors.black)), onPressed: onCopyPressed))
    ]));


    var stack = Stack(children: <Widget>[
      headerAndLoggingList, btnRightBtns
    ],);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: stack),
    );
  }
}