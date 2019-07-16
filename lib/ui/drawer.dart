import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MenuDrawerState();
}

class MenuDrawerState extends State<MenuDrawer> {
  final Color bgColor = Color(0xFFEAEDF2);
  final Color headerBorderColor = Color(0xFFCCCCCC);
  final Color selectedFontColor = Color(0xFF415990);

  @override
  Widget build(BuildContext context) {
    Widget DrawerItem(String text, Function onItemTap, bool selected) {
      return Padding(
        padding: EdgeInsets.all(5),
        child: SizedBox(
          width: double.infinity,
          child: Material(
              color: selected ? bgColor : Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3)),
              child: InkWell(
                onTap: onItemTap,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(text, style: TextStyle(color: selected ? selectedFontColor : Colors.black)),
                ),
              )
          ),
        ),
      );
    }

    return Drawer(
      child: Container(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      constraints: BoxConstraints.expand(height: 60),
                      decoration: BoxDecoration(color: bgColor, border: Border(bottom: BorderSide(color: headerBorderColor))),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const <Widget>[
                            Text(
                              'Irina Baird',
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.left,
                            ),
                            Text('irina')
                          ],
                        ),
                      ),
                    ),
                    DrawerItem('My Tasks', (){}, true),
                    DrawerItem('Work Orders', (){}, false),
                    DrawerItem('Manager Summary', (){}, false),
                    DrawerItem('My Profile', (){}, false),
                    DrawerItem('Help', (){}, false),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: (){

                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('LOG OUT', style: TextStyle(color: Colors.red)),
                  ),
                ),
              )
            ],
          ),
          constraints: BoxConstraints.expand()),
    );
  }
}
