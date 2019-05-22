import 'dart:io';

import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizElevated.dart';

typedef void OnCustomBackButtonActionTapped();

class ActionBar extends StatefulWidget implements PreferredSizeWidget {
  final OnCustomBackButtonActionTapped onCustomBackButtonActionTapped;
  final double barHeight = Platform.isIOS ? 60.0 : 65.0;
  final Widget tailWidget;
  final Widget leadingWidget;
  final List<Widget> centralWidgets;

  final String title;
  final Color titleColor;

  ActionBar({this.title, this.leadingWidget, this.tailWidget, this.centralWidgets, this.titleColor = const Color(0xFF0073C1), this.onCustomBackButtonActionTapped});


  @override
  ActionBarState createState() => ActionBarState();

  // TODO: implement preferredSize
  @override
  Size get preferredSize => Size.fromHeight(barHeight);
}

class ActionBarState extends State<ActionBar> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = List<Widget>();
    SizedBox leadingContainer;

    //the backbutton when the view can pop
    if (Navigator.of(context).canPop()) {
      VizButton backBtn = VizButton(title: 'Back', onTap: (){
        if(widget.onCustomBackButtonActionTapped!=null){
          widget.onCustomBackButtonActionTapped();
        }
        Navigator.maybePop(context);
      });

      leadingContainer = SizedBox(width: 100.0, child: Flex(direction: Axis.horizontal, children: <Widget>[backBtn]));
    } else if (widget.leadingWidget != null) {
      leadingContainer = SizedBox(width: 100.0, child: Flex(direction: Axis.horizontal, children: <Widget>[widget.leadingWidget]));
    }

    if (leadingContainer != null)
      children.add(leadingContainer);

    //centered title
    if (widget.centralWidgets == null) {
      List<Color> customBackground = [const Color(0xFF515151), const Color(0xFF060606)];
      Color customBorderColor = Colors.black;

      children.add(Expanded(child: VizElevated(title: widget.title, textColor: widget.titleColor, customBackground: customBackground, customBorderColor: customBorderColor)));
    } else {
      children = List.from(children)..addAll(widget.centralWidgets);
    }

    if (widget.tailWidget != null) {
      var tailingContainer = SizedBox(width: 100.0, child: Flex(direction: Axis.horizontal, children: <Widget>[widget.tailWidget]));

      children.add(tailingContainer);
    }

    List<Color> _colors = [
      const Color(0xFFE4EDEF),
      const Color(0xFFB1C6CF),
    ];

    LinearGradient gradient = LinearGradient(colors: _colors, begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated);
    BoxDecoration boxDecoration = BoxDecoration(gradient: gradient);

    //var topMargin = Platform.isIOS? 0.0: 21.0;

    const paddingIOS = EdgeInsets.only(left: 2.0, bottom: 2.0, right: 2.0);
    const paddingAndroid = EdgeInsets.only(left: 2.0, bottom: 2.0, right: 2.0);

    Container container = Container(
      //margin: EdgeInsets.only(top: topMargin),
      height: widget.barHeight,
      padding: Platform.isIOS ? paddingIOS : paddingAndroid,
      decoration: boxDecoration,
      child: Row(
        children: children,
      ),
    );

    return SafeArea(child: container, bottom: false);
  }
}
