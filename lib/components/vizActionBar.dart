import 'package:flutter/material.dart';
import 'package:techviz/components/vizBackButton.dart';
import 'package:techviz/components/vizElevated.dart';

class ActionBar extends StatefulWidget implements PreferredSizeWidget {
  ActionBar(
      {this.title,
      this.leadingWidget,
      this.tailWidget,
      this.centralWidgets,
      this.titleColor});

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

    var leadingContainer;
    //the backbutton when the view can pop
    if (canPop) {
      leadingContainer = SizedBox(
          width: 100.0,
          child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[VizBackButton()]));
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
      children.add(Expanded(
          child: VizElevated(
              title: widget.title, textColor: widget.titleColor)));
    } else {
      children = List.from(children)..addAll(widget.centralWidgets);
    }

    var container = Container(
      height: widget.barHeight,
      color: Colors.black,
      child: Row(
        children: children,
      ),
    );

    return container;
  }
}
