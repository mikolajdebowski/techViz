import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:techviz/components/vizListView.dart';
import 'package:techviz/components/vizShimmer.dart';
import 'package:techviz/model/dataEntry.dart';

class VizListViewRow extends StatefulWidget {
  static final double rowHeight = 35.0;
  final DataEntry dataEntry;
  final SwipeAction onSwipeLeft;
  final SwipeAction onSwipeRight;

  const VizListViewRow(this.dataEntry, {Key key, this.onSwipeLeft, this.onSwipeRight}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizListViewRowState();
}

class VizListViewRowState extends State<VizListViewRow> {
  final double rowHeight = 35.0;
  final GlobalKey<SlidableState> _slidableKey = GlobalKey<SlidableState>();

  bool isBeingPressed = false;

  Container createShimmer(String _txt, String _direction) {
    return Container(
        child: Shimmer.fromColors(
      direction: _direction,
      baseColor: Colors.white,
      highlightColor: Colors.grey,
      child: Text(
        _txt,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Color bgRowColor = isBeingPressed ? Colors.lightBlue : Colors.transparent;
    BoxDecoration decoration = BoxDecoration(color: bgRowColor, border: Border(bottom: BorderSide(color: Colors.black, width: 1.0)));

    List<Widget> columns = List<Widget>();

    widget.dataEntry.columns.forEach((DataEntryCell dataCell) {
      String text = dataCell.toString();
      TextStyle style = TextStyle(fontSize: text.length >= 20 ? 10 : 12);

      TextAlign align = dataCell.alignment == DataAlignment.left ? TextAlign.left : (dataCell.alignment == DataAlignment.right ? TextAlign.right : TextAlign.center);

      columns.add(Expanded(
          child: Text(
        text,
        textAlign: align,
        style: style,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        maxLines: 2,
      )));
    });

    Row dataRow = Row(
      children: columns,
    );

    List<Widget> leftActions = List<Widget>();
    if (widget.onSwipeLeft != null) {
      SwipeButton swipeButton = SwipeButton(
          btnCol: Color(0xFF96CF96),
          text: widget.onSwipeLeft.title,
          onPressed: () {
            widget.onSwipeLeft.callback(widget.dataEntry);
          });

      Container swipeButtonContainer = Container(
        decoration: decoration,
        child: swipeButton,
      );

      leftActions.add(swipeButtonContainer);
    }

    List<Widget> rightActions = List<Widget>();
    if (widget.onSwipeRight != null) {
      SwipeButton swipeButton = SwipeButton(
          btnCol: Colors.white70,
          text: widget.onSwipeRight.title,
          onPressed: () {
            widget.onSwipeRight.callback(widget.dataEntry);
          });

      Container swipeButtonContainer = Container(
        decoration: decoration,
        child: swipeButton,
      );

      rightActions.add(swipeButtonContainer);
    }

    Slidable slidable = Slidable(
      key: _slidableKey,
      controller: SlidableController(),
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        decoration: decoration,
        height: VizListViewRow.rowHeight,
        child: dataRow,
      ),
      actions: rightActions,
      secondaryActions: leftActions,
      dismissal: SlidableDismissal(
        dismissThresholds: <SlideActionType, double>{SlideActionType.secondary: 1.0, SlideActionType.primary: 1.0},
        child: SlidableDrawerDismissal(),
        onDismissed: (actionType) {},
      ),
    );

    GestureDetector gestureDetector = GestureDetector(
        child: slidable,
        onTap: () {
          SlidableState slidableState = _slidableKey.currentState;
          slidableState.close();
          setState(() {
            this.isBeingPressed = false;
          });
        }
      );

    Listener listener = Listener(
      child: gestureDetector,
      onPointerDown: (PointerDownEvent event) {
        setState(() {
          this.isBeingPressed = true;
        });
      },
      onPointerUp: (PointerUpEvent event) {
        setState(() {
          this.isBeingPressed = false;
        });
      },
    );

    Stack stack = Stack(
      children: <Widget>[
        listener,
        Opacity(
          opacity: (isBeingPressed && (widget.onSwipeLeft != null)) ? 1.0 : 0.0,
          child: Align(
            child: createShimmer('<', 'rtl'),
            alignment: Alignment.centerLeft,
          ),
        ),
        Opacity(
            opacity: (isBeingPressed && (widget.onSwipeRight != null)) ? 1.0 : 0.0,
            child: Align(
              child: createShimmer('>', 'ltr'),
              alignment: Alignment.centerRight,
            ))
      ],
    );

    return stack;
  }
}
