import 'package:flutter/material.dart';
import 'package:techviz/components/vizBackButton.dart';
import 'package:techviz/components/vizElevatedButton.dart';

class ActionBar extends StatefulWidget implements PreferredSizeWidget {

  ActionBar(this.title, {this.leadingWidget, this.tailWidget, this.actionWidgets});

  final double barHeight = 65.0;
  final String title;
  final Widget tailWidget;
  final Widget leadingWidget;
  final List<Widget> actionWidgets;


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

    //the backbutton when the view can pop
    var containsLeading = false;
    if(canPop){
      children.add(new VizBackButton());
      containsLeading = true;
    }
    else if(widget.leadingWidget != null){
      children.add(widget.leadingWidget);
      containsLeading = true;
    }



    //centered title
    var titleWidget = new VizElevatedButton(title: widget.title);
    children.add(titleWidget);

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
