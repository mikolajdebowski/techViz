
import 'package:flutter/material.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/ui/home.dart';

class HomeManager extends StatefulWidget {
  HomeManager(Key key) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeManagerState();
}

class HomeManagerState extends State<HomeManager> implements TechVizHome {
  @override
  Widget build(BuildContext context) {

    BoxDecoration boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Color(0xFFFFFFFF)),
        gradient: LinearGradient(colors: [Color(0xFF81919D), Color(0xFFAAB7BD)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated));


    Column column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: (Container(decoration: boxDecoration, child: Center(child: Text('Open tasks'),)))),
        SizedBox(height: 5),
        Expanded(child: (Container(decoration: boxDecoration, child: Center(child: Text('Team Availability'),)))),
        SizedBox(height: 5),
        Expanded(child: (Container(decoration: boxDecoration, child: Center(child: Text('Slot Floor Summary'),)))),
      ],
    );

    Container container = Container(
      child: Padding(child: column, padding: EdgeInsets.all(5.0)),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
    );

    return container;

  }

  @override
  void onUserSectionsChanged(Object obj) {
    // TODO: implement onUserSectionsChanged
  }

  @override
  void onUserStatusChanged(UserStatus us) {
    // TODO: implement onUserStatusChanged
  }
}