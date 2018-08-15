import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/home.dart';

class RoleSelector extends StatefulWidget {
  RoleSelector({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RoleSelectorState();
}

class RoleSelectorState extends State<RoleSelector> {
  List<VizSelectorOption> options = List<VizSelectorOption>();

  @override
  void initState(){
    super.initState();

    options.add(VizSelectorOption("1", "Available"));
    options.add(VizSelectorOption("2", "Off shift"));

  }


  void onOkTap() {
    Navigator.pushReplacement(context, MaterialPageRoute<Home>(builder: (BuildContext context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    var defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));

    var okBtn = VizButton('OK', onTap: onOkTap, highlighted: true);




    var body = GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.all(4.0),
      childAspectRatio: options.length > 4 ? 1.0 : 2.0,
      addAutomaticKeepAlives: false,
      crossAxisCount: options.length > 6 ? 6 : options.length,
      children: options.map((VizSelectorOption option) {
      return VizOptionButton(
      option.description,
      key: GlobalKey(),
      selected: option.selected);
     }).toList());


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'My Role', titleColor: Colors.blue, isRoot: true, tailWidget:okBtn),
      body: Container(
        decoration: defaultBgDeco,
        constraints: BoxConstraints.expand(),
        child: body,
      ),
    );
  }


  void onSelectAllTapped() {
    if (options != null) {
      setState(() {
        options.forEach((option) {
          option.selected = true;
        });
      });
    }
  }

  void onSelectNoneTapped() {
    if (options != null) {
      setState(() {
        options.forEach((option) {
          option.selected = false;
        });
      });
    }
  }

}

class VizSelectorOption {
  VizSelectorOption(this.id, this.description, {this.selected = false});

  Object id;
  String description;
  bool selected;
}
