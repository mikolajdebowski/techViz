import 'package:flutter/material.dart';
import 'package:techviz/components/vizBackButton.dart';
import 'package:techviz/components/vizElevated.dart';

class ActionBar extends StatefulWidget implements PreferredSizeWidget {
  ActionBar(
      {this.title,
      this.leadingWidget,
      this.tailWidget,
      this.centralWidgets,
      this.titleColor = const Color(0xFF0073C1)});

  final double barHeight = 65.0;
  final Widget tailWidget;
  final Widget leadingWidget;
  final List<Widget> centralWidgets;

  final String title;
  final Color titleColor;

  _ActionBarState createState() => _ActionBarState();

  // TODO: implement preferredSize
  @override
  Size get preferredSize => Size.fromHeight(barHeight);
}

class _ActionBarState extends State<ActionBar> {
  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic> parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    List<Widget> children = List<Widget>();

    SizedBox leadingContainer;

    //the backbutton when the view can pop
    if (canPop) {
      leadingContainer = SizedBox(
          width: 100.0,
          child: Flex(
              direction: Axis.horizontal, children: <Widget>[VizBackButton()]));
    } else if (widget.leadingWidget != null) {
      leadingContainer = SizedBox(
          width: 100.0,
          child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[widget.leadingWidget]));
    }
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

    var container = Container(
      height: widget.barHeight,
      padding: const EdgeInsets.all(4.0),
      decoration: boxDecoration,
      child: Row(
        children: children,
      ),
    );

    return container;
  }
}
