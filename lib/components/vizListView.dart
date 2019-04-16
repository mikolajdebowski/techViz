import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

typedef SwipeActionCallback = void Function(dynamic tag);

class SwipeAction{
  final String title;
  final SwipeActionCallback callback;

  SwipeAction(this.title, this.callback);
}

class VizListView extends StatefulWidget{
  final List<RowObject> data;
  final SwipeAction callbackLeft;
  final SwipeAction callbackRight;

  const VizListView({Key key, this.data, this.callbackLeft, this.callbackRight}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizListViewState();
}

class VizListViewState extends State<VizListView>{
  final SlidableController slidableController = new SlidableController();
  final double paddingValue = 10.0;

  @override
  Widget build(BuildContext context) {

    List<Slidable> listOfRows = widget.data.map((RowObject row){

      Row dataRow = Row(
        children: <Widget>[
          Expanded(child: Text(row.location)),
          Expanded(child: Text(row.status)),
          Expanded(child: Text(row.type)),
          Expanded(child: Text(row.user)),
          Expanded(child: Text(row.time))
        ],
      );
      
      Padding padding = Padding(
        child: dataRow, padding: EdgeInsets.all(paddingValue),
      );

      List<GestureDetector> leftActions = List<GestureDetector>();
      if(widget.callbackLeft!=null){
        leftActions.add(GestureDetector(
          onTap: (){
            widget.callbackLeft.callback;
          },
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Text(widget.callbackLeft.title),
          ),
        ));
      }

      List<GestureDetector> rightActions = List<GestureDetector>();
      if(widget.callbackRight!=null){
        rightActions.add(GestureDetector(
          onTap: (){
            widget.callbackRight.callback;
          },
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Text(widget.callbackRight.title),
          ),
        ));
      }

      Slidable slidable = Slidable(
        controller: slidableController,
        delegate: SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child:  Container(
          child:  padding,
        ),
        actions: rightActions,
        secondaryActions: leftActions
      );

      return slidable;
    }).toList();

    return ListView(
        children: listOfRows
    );
  }
}

class RowObject{
  final String location;
  final String type;
  final String status;
  final String user;
  final String time;

  RowObject({this.location, this.type, this.status, this.user, this.time});

  bool selected = false;

  @override
  String toString(){
    return location;
  }
}


class SlideMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menuItems;

  SlideMenu({this.child, this.menuItems});

  @override
  _SlideMenuState createState() => new _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = new Tween(
        begin: const Offset(0.0, 0.0),
        end: const Offset(-0.2, 0.0)
    ).animate(new CurveTween(curve: Curves.decelerate).animate(_controller));

    return new GestureDetector(
      onHorizontalDragUpdate: (data) {
        // we can access context.size here
        setState(() {
          _controller.value -= data.primaryDelta / context.size.width;
        });
      },
      onHorizontalDragEnd: (data) {
        if (data.primaryVelocity > 2500)
          _controller.animateTo(.0); //close menu on fast swipe in the right direction
        else if (_controller.value >= .5 || data.primaryVelocity < -2500) // fully open if dragged a lot to left or on fast swipe to left
          _controller.animateTo(1.0);
        else // close if none of above
          _controller.animateTo(.0);
      },
      child: new Stack(
        children: <Widget>[
          new SlideTransition(position: animation, child: widget.child),
          new Positioned.fill(
            child: new LayoutBuilder(
              builder: (context, constraint) {
                return new AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return new Stack(
                      children: <Widget>[
                        new Positioned(
                          right: .0,
                          top: .0,
                          bottom: .0,
                          width: constraint.maxWidth * animation.value.dx * -1,
                          child: new Container(
                            color: Colors.black26,
                            child: new Row(
                              children: widget.menuItems.map((child) {
                                return new Expanded(
                                  child: child,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}