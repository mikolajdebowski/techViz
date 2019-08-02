import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dataEntry/dataEntry.dart';
import 'dataEntry/dataEntryColumn.dart';
import 'vizListViewRow.dart';

typedef SwipeActionCallback = void Function(dynamic tag);
typedef OnScroll = void Function(ScrollingStatus scroll);
typedef Swipable = bool Function(dynamic parameter);

class VizListView extends StatefulWidget {
  final List<DataEntry> data;
  final SwipeAction onSwipeLeft;
  final SwipeAction onSwipeRight;
  final OnScroll onScroll;
  final String noDataMessage;
  final double maxHeight;
  final List<DataEntryColumn> columnsDefinition;

  VizListView(this.data, this.columnsDefinition, {Key key, this.onSwipeLeft, this.onSwipeRight, this.onScroll, this.noDataMessage, this.maxHeight}) : super(key: key){
    assert(data!=null);
    assert(columnsDefinition!=null);
  }

  @override
  State<StatefulWidget> createState() => VizListViewState();
}

class VizListViewState extends State<VizListView> {
  final double paddingValue = 5.0;
  static const double _sortArrowPadding = 2.0;
  static const double _headingFontSize = 12.0;
  static const Duration _sortArrowAnimationDuration = Duration(milliseconds: 150);

  ScrollController _scrollController;
  GlobalKey<SlidableState> _lastRowkey;

  @override
  void initState() {
    _scrollController = ScrollController();

    if(widget.onScroll!=null){
      _scrollController.addListener(() {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
          widget.onScroll(ScrollingStatus.ReachOnBottom);
        } else if (_scrollController.offset <= _scrollController.position.minScrollExtent) {
          widget.onScroll(ScrollingStatus.ReachOnTop);
        }
      });
    }

    super.initState();
  }


  void onRowSwiping(bool isOpen, GlobalKey<SlidableState> key){
    if(_lastRowkey==null){
      setState(() {
        _lastRowkey = key;
      });
    }
    else if(_lastRowkey!=null && _lastRowkey.hashCode != key.hashCode){
      if(_lastRowkey.currentState != null){
        _lastRowkey.currentState.close();
      }

      setState(() {
        _lastRowkey = key;
      });
    }
  }


  // ignore: unused_element
  Widget _buildHeadingCell({
    BuildContext context,
    Widget label,
    String tooltip,
    bool numeric,
    VoidCallback onSort,
    bool sorted,
    bool ascending,
  }) {
    if (onSort != null) {
      final Widget arrow = _SortArrow(
        visible: sorted,
        down: sorted ? ascending : null,
        duration: _sortArrowAnimationDuration,
      );
      const Widget arrowPadding = SizedBox(width: _sortArrowPadding);
      label = Row(
        textDirection: numeric ? TextDirection.rtl : null,
        children: <Widget>[ label, arrowPadding, arrow ],
      );
    }
    label = Container(
//      height: headingRowHeight,
      alignment: numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: AnimatedDefaultTextStyle(
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: _headingFontSize,
//          height: math.min(1.0, headingRowHeight / _headingFontSize),
          color: (Theme.of(context).brightness == Brightness.light)
              ? ((onSort != null && sorted) ? Colors.black87 : Colors.black54)
              : ((onSort != null && sorted) ? Colors.white : Colors.white70),
        ),
        softWrap: false,
        duration: _sortArrowAnimationDuration,
        child: label,
      ),
    );
    if (tooltip != null) {
      label = Tooltip(
        message: tooltip,
        child: label,
      );
    }
    if (onSort != null) {
      label = InkWell(
        onTap: onSort,
        child: label,
      );
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null || widget.data.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: paddingValue, bottom: paddingValue),
          child: Text(widget.noDataMessage != null ? widget.noDataMessage : 'No data'),
        ),
      );
    }

    List<Widget> header = <Widget>[];

    widget.columnsDefinition.forEach((DataEntryColumn column){
      if(!column.visible)
        return;

//      final Widget arrow = _buildHeadingCell(
//        context: context,
//        label: Text(
//          dataCell.column.toString(),
//          textAlign: TextAlign.center,
//          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//        ),
//        tooltip: "",
//        numeric: false,
//        onSort: (){
//          print('sort');
//        },
//        sorted: true,
//        ascending: true,
//      );
//
//      header.add(Expanded(
//          child: arrow
//      ));

      header.add(Expanded(
          flex: column.flex,
          child: Text(
            column.columnName.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          )));

    });

    //HEADER
    Row headerRow = Row(
      children: header,
    );

    //LISTVIEW
    List<VizListViewRow> rowsList =
    widget.data.map((DataEntry row) => VizListViewRow(row, widget.columnsDefinition, onSwipeLeft: widget.onSwipeLeft, onSwipeRight: widget.onSwipeRight, onSwiping: onRowSwiping)).toList();

    double maxHeight = widget.maxHeight !=null ? widget.maxHeight : MediaQuery.of(context).size.height;
    maxHeight += 15; //THIS "MARGIN" IS INTENTIONAL, SO USER CAN SEE THAT THERE ARE MORE DATA IN THE LIST

    Container listViewContainer = Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView(
        controller: _scrollController,
        children: rowsList,
      ),
    );

    return SingleChildScrollView(
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          decoration: BoxDecoration(color: Color(0xFFF1F1F1)),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: headerRow,
          )),
        listViewContainer]),
    );
  }
}

class SwipeButton extends StatelessWidget {
  const SwipeButton({@required this.onPressed, @required this.text, this.color});

  final Color color;
  final GestureTapCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        color:  onPressed == null ? Color(0xFFC1C1C1): color,
        splashColor: onPressed == null ? Color(0xFFC1C1C1) : color,
        child: AutoSizeText(
          text,
          maxLines: 1,
          style: TextStyle(color: onPressed == null ? Colors.grey[200]: Colors.white , fontSize: 10),
        ),
        onPressed: (){
          if(onPressed!=null){
            onPressed();
          }
        },
        materialTapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
    );
  }
}

enum ScrollingStatus { ReachOnTop, ReachOnBottom, IsScrolling }


class _SortArrow extends StatefulWidget {
  const _SortArrow({
    Key key,
    this.visible,
    this.down,
    this.duration,
  }) : super(key: key);

  final bool visible;

  final bool down;

  final Duration duration;

  @override
  _SortArrowState createState() => _SortArrowState();
}

class _SortArrowState extends State<_SortArrow> with TickerProviderStateMixin {

  AnimationController _opacityController;
  Animation<double> _opacityAnimation;

  AnimationController _orientationController;
  Animation<double> _orientationAnimation;
  double _orientationOffset = 0.0;

  bool _down;

  static final Animatable<double> _turnTween = Tween<double>(begin: 0.0, end: math.pi)
      .chain(CurveTween(curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _opacityAnimation = CurvedAnimation(
      parent: _opacityController = AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
      curve: Curves.fastOutSlowIn,
    )
      ..addListener(_rebuild);
    _opacityController.value = widget.visible ? 1.0 : 0.0;
    _orientationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _orientationAnimation = _orientationController.drive(_turnTween)
      ..addListener(_rebuild)
      ..addStatusListener(_resetOrientationAnimation);
    if (widget.visible)
      _orientationOffset = widget.down ? 0.0 : math.pi;
  }

  void _rebuild() {
    setState(() {
      // The animations changed, so we need to rebuild.
    });
  }

  void _resetOrientationAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      assert(_orientationAnimation.value == math.pi);
      _orientationOffset += math.pi;
      _orientationController.value = 0.0; // TODO(ianh): This triggers a pointless rebuild.
    }
  }

  @override
  void didUpdateWidget(_SortArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool skipArrow = false;
    final bool newDown = widget.down ?? _down;
    if (oldWidget.visible != widget.visible) {
      if (widget.visible && (_opacityController.status == AnimationStatus.dismissed)) {
        _orientationController.stop();
        _orientationController.value = 0.0;
        _orientationOffset = newDown ? 0.0 : math.pi;
        skipArrow = true;
      }
      if (widget.visible) {
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }
    if ((_down != newDown) && !skipArrow) {
      if (_orientationController.status == AnimationStatus.dismissed) {
        _orientationController.forward();
      } else {
        _orientationController.reverse();
      }
    }
    _down = newDown;
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _orientationController.dispose();
    super.dispose();
  }

  static const double _arrowIconBaselineOffset = -1.5;
  static const double _arrowIconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacityAnimation.value,
      child: Transform(
        transform: Matrix4.rotationZ(_orientationOffset + _orientationAnimation.value)
          ..setTranslationRaw(0.0, _arrowIconBaselineOffset, 0.0),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_downward,
          size: _arrowIconSize,
          color: (Theme.of(context).brightness == Brightness.light) ? Colors.black87 : Colors.white70,
        ),
      ),
    );
  }

}