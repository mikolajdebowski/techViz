import 'dart:io';

import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizElevated.dart';

class ActionBar extends StatefulWidget implements PreferredSizeWidget {
  ActionBar(
      {this.title,
      this.leadingWidget,
      this.tailWidget,
      this.centralWidgets,
      this.titleColor = const Color(0xFF0073C1),
      this.isRoot = false});

  final double barHeight = Platform.isIOS? 70.0: 65.0;
  final Widget tailWidget;
  final Widget leadingWidget;
  final List<Widget> centralWidgets;
  final bool isRoot;

  final String title;
  final Color titleColor;

  _ActionBarState createState() => _ActionBarState();

  // TODO: implement preferredSize
  @override
  Size get preferredSize => Size.fromHeight(barHeight);
}

class _ActionBarState extends State<ActionBar> {

  void goBack(){
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List<Widget>();
    SizedBox leadingContainer;

    //the backbutton when the view can pop
    if (widget.isRoot == false) {
      VizButton backBtn = VizButton(title: 'Back', onTap: goBack);

      leadingContainer = SizedBox(
          width: 100.0,
          child: Flex(
              direction: Axis.horizontal, children: <Widget>[backBtn]));
    } else if (widget.leadingWidget != null) {
      leadingContainer = SizedBox(
          width: 100.0,
          child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[widget.leadingWidget]));
    }

    if(leadingContainer!=null)
      children.add(leadingContainer);

    //centered title
    if (widget.centralWidgets == null) {
      var customBackground = [const Color(0xFF515151), const Color(0xFF060606)];
      var customBorderColor = Colors.black;

      children.add(Expanded(
          child:
              VizElevated(title: widget.title, textColor: widget.titleColor, customBackground: customBackground, customBorderColor: customBorderColor)));
    } else {
      children = List.from(children)..addAll(widget.centralWidgets);
    }

    if(widget.tailWidget != null){
      var tailingContainer = SizedBox(
          width: 100.0,
          child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[widget.tailWidget]));

      children.add(tailingContainer);

    }

    var _colors = [
      const Color(0xFFE4EDEF),
      const Color(0xFFB1C6CF),
    ];

    var gradient = LinearGradient(
        colors: _colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.repeated);

    var boxDecoration = BoxDecoration(
        gradient: gradient);

    var topMargin = Platform.isIOS? 0.0: 21.0;

    const paddingIOS = EdgeInsets.only(left: 2.0, bottom: 2.0, right: 2.0);
    const paddingAndroid = EdgeInsets.only(left: 2.0, bottom: 2.0, right: 2.0);

    var container = Container(
      //margin: EdgeInsets.only(top: topMargin),
      height: widget.barHeight,
      padding: Platform.isIOS ? paddingIOS: paddingAndroid,
      decoration: boxDecoration,
      child: Row(
        children: children,
      ),
    );

    return SafeArea(child: container, bottom: false);
  }


}
