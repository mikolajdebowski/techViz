import 'package:flutter/material.dart';
import 'package:techviz/components/vizBackButton.dart';
import 'package:techviz/components/vizElevatedButton.dart';
import 'package:techviz/components/vizExpandedButton.dart';

class ActionBar extends StatefulWidget implements PreferredSizeWidget {

  ActionBar(this.title, {this.leadingWidget, this.tailWidget, this.centralWidgets, this.titleColor});

  final double barHeight = 65.0;
  final Widget tailWidget;
  final Widget leadingWidget;
  final List<Widget> centralWidgets;

  final String title;
  final Color titleColor;

  _ActionBarState createState() => new _ActionBarState();

  // TODO: implement preferredSize
  @override
  Size get preferredSize => new Size.fromHeight(barHeight);
}

class _ActionBarState extends State<ActionBar>{

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic> parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    List<Widget> children = new List<Widget>();

    var leadingContainer;
    //the backbutton when the view can pop
    if(canPop){
      leadingContainer  = new SizedBox(width: 100.0, child: new Flex(direction: Axis.horizontal ,children: <Widget>[new VizBackButton()]));
    }
    else if(widget.leadingWidget != null){
      leadingContainer  = new SizedBox(width: 100.0, child: new Flex(direction: Axis.horizontal ,children: <Widget>[widget.leadingWidget]));
    }
    children.add(leadingContainer);

    //centered title
    if(widget.centralWidgets == null){
      children.add(new VizExpandedButton(title: widget.title, textColor: widget.titleColor));
    }
    else{
      children = new List.from(children)..addAll(widget.centralWidgets);
    }

   var container = new Container(
        height: widget.barHeight,
        color: Colors.black,
        child: new Row(
            children: children,
          ),
    );

    return container;
  }

}
