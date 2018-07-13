import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';

class Menu extends StatefulWidget {
  Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: ActionBar(title: 'Menu'),
        body: Center(child: Text('Menu', style: TextStyle(color: Colors.white))));
  }
}
