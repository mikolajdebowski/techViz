import 'package:flutter/material.dart';

class AttendantHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AttendantHomeState();
}

class AttendantHomeState extends State<AttendantHome> {
  @override
  Widget build(BuildContext context) {
    //the header
    var rowHeader = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('Active Task',
                      style: TextStyle(color: Colors.grey))),
              Text('01-01-21',
                  style: TextStyle(color: Colors.lightBlue, fontSize: 22.0))
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(4.0),
                  child:
                      Text('Task Type', style: TextStyle(color: const Color(0xFF8CAFB6)))),
              Text('Jackpot',
                  style: TextStyle(color: Colors.white, fontSize: 22.0))
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text('Task Status',
                      style: TextStyle(color: Colors.grey))),
              Text('Acknowledged',
                  style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold))
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(4.0),
                  child:
                      Text('Time Taken', style: TextStyle(color: Colors.grey))),
              Text('0:22', style: TextStyle(color: Colors.teal, fontSize: 30.0))
            ],
          ),
        )
      ],
    );

    var headerBody = Container(
      height: 65.0,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [const Color(0xFF4D4D4D), const Color(0xFF000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.repeated)),
      child: rowHeader,
    );

    //task list part
    var listTasks = <Widget>[];

    for (var i = 1; i < 2; i++) {
      var taskItem = Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              height: 70.0,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                    const Color(0xFF45505D),
                    const Color(0xFF282B34)
                  ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.repeated)),
              child: Center(
                  child: Text(i.toString(),
                      style: TextStyle(color: Colors.white))),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: 70.0,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                    const Color(0xFFB2C7CF),
                    const Color(0xFFE4EDEF)
                  ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.repeated)),
              child: Center(child: Text('01-01-0' + i.toString(), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),)),
            ),
          ),
        ],
      );

      listTasks.add(taskItem);
    }

    var taskList = Flexible(
      flex: 1,
      child: ListView(
        children: listTasks,
      ),
    );

    BoxDecoration actionBoxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: const Color(0xFFFFFFFF)),
        gradient: LinearGradient(
            colors: [const Color(0xFF81919D), const Color(0xFFAAB7BD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.repeated));

    var requiredAction = Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(5.0),
            child:
                Text('Required Action', style: TextStyle(color: Colors.white))),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: actionBoxDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ImageIcon(
                          new AssetImage("assets/images/ic_barcodescanner.png"),
                          size: 150.0,
                          color: Colors.white),
                      Center(
                          child: Text('Scan Machine',
                              style: TextStyle(
                                  color: const Color(0xFF426184),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold)))
                    ],
                  ),
                ))),
      ],
    );

    //main container
    var mainContainer = Flexible(
        flex: 3,
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 3,
              child: requiredAction,
            ),
            Flexible(
              flex: 1,
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                              const Color(0xFFB2C7CF),
                              const Color(0xFFE4EDEF)
                            ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                tileMode: TileMode.repeated)),
                        child: Center(child: Text('Complete')),
                      )),
                      Container(
                          width: 10.0,
                          color: const Color(0xFF6EBD24),
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
                                colors: [
                              const Color(0xFFB2C7CF),
                              const Color(0xFFE4EDEF)
                            ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                tileMode: TileMode.repeated)),
                        child: Center(child: Text('Cancel')),
                      )),
                      Container(
                          width: 10.0,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                const Color(0xFFFF6600),
                                const Color(0xFFFFE100)
                              ],
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
                                    colors: [
                                  const Color(0xFFB2C7CF),
                                  const Color(0xFFE4EDEF)
                                ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    tileMode: TileMode.repeated)),
                            child: Center(child: Text('Escalate')),
                          ),
                        ),
                        Container(
                            width: 10.0,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                  const Color(0xFF433177),
                                  const Color(0xFFF2003C)
                                ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    tileMode: TileMode.repeated)))
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));

    //body
    var gradientBody = LinearGradient(
        colors: [const Color(0xFF586676), const Color(0xFF8B9EA7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.repeated);

    var boxDecorationBody = BoxDecoration(gradient: gradientBody);

    var body = Expanded(
        child: Container(
      decoration: boxDecorationBody,
      child: Row(
        children: <Widget>[taskList, mainContainer],
      ),
    ));

    //return the whole view
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[headerBody, body],
    );
  }
}
