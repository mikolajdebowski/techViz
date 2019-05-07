import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';


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
    return Scaffold(backgroundColor: Colors.black, appBar: ActionBar(title: 'About'));
  }

}



