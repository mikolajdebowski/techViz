
import 'package:flutter/material.dart';
import 'package:techviz/model/task.dart';
import 'package:animator/animator.dart';

typedef VizTaskListItemCallback = void Function(Task task);


class VizTaskItem extends StatefulWidget{
  final Task task;
  final VizTaskListItemCallback itemTapCallback;
  final int index;
  final bool selected;

  const VizTaskItem(this.task, this.index, this.itemTapCallback, this.selected, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizTaskItemState();
}

class VizTaskItemState extends State<VizTaskItem>{
  bool userHasTapped;

  @override
  void initState() {
    userHasTapped = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color urgencyColorStart = widget.task.urgencyHEXColor != null ? Color(int.parse("0xFF${widget.task.urgencyHEXColor}")) : Color(0xFF45505D);
    Color urgencyColorEnd = widget.task.urgencyHEXColor != null ? Color(int.parse("0xAA${widget.task.urgencyHEXColor}")) : Color(0xFF45505D);

    List<Color> mainBackgroundColor = widget.selected ? [Color(0xFF65b1d9), Color(0xFF0268a2)] : [Color(0xFFB2C7CF), Color(0xFFE4EDEF)];
    Color locationColor = widget.selected ? Colors.white : Colors.black45;

    Widget statusIcon = userHasTapped == false ?
    VizTaskItemSyncStatus(VizTaskItemSyncStatusType.New) :
        widget.task.dirty == 0 ? VizTaskItemSyncStatus(VizTaskItemSyncStatusType.Waiting) : VizTaskItemSyncStatus(VizTaskItemSyncStatusType.Syncing);

    return GestureDetector(
        onTap: () {
          setState(() {
            userHasTapped = true;
          });
          widget.itemTapCallback(widget.task);
        },
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                height: 55.0,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [urgencyColorStart,urgencyColorEnd],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        tileMode: TileMode.repeated)),
                child: Center(child: Text(widget.index.toString(), style: TextStyle(color: Colors.white))),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                height: 55.0,
                decoration:
                BoxDecoration(gradient: LinearGradient(colors: mainBackgroundColor, begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(padding: EdgeInsets.only(right: 5.0, top: 5.0), child: statusIcon),
                    ),
                    Center(
                        child: Text(
                          widget.task.location,
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0, color: locationColor),
                        ))
                  ],

                ),
              ),
            ),
          ],
        ));
  }
}



class VizTaskItemSyncStatus extends StatelessWidget{

  final VizTaskItemSyncStatusType statusType;
  const VizTaskItemSyncStatus(this.statusType);

  @override
  Widget build(BuildContext context) {

    if(statusType == VizTaskItemSyncStatusType.Waiting)
      return Container();

    if(statusType == VizTaskItemSyncStatusType.New)
      return Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue), height: 7, width: 7);

    return Animator(
      tween: ColorTween(begin: Colors.transparent, end: Colors.red),
      cycles: 0,
      duration: Duration(seconds: 1),
      builder: (anim){
        return Container(decoration: BoxDecoration(shape: BoxShape.circle, color: anim.value), height: 7, width: 7);
      },
    );
  }
}

enum VizTaskItemSyncStatusType{
  Waiting, New, Syncing
}
