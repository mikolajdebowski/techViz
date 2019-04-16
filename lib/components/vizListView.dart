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

  @override
  Widget build(BuildContext context) {

    List<Slidable> listOfRows = widget.data.map((RowObject row){

      Row dataRow = Row(
        children: <Widget>[
          Text(row.location),
          Text(row.status),
          Text(row.type)
        ],
      );
      
      Padding padding = Padding(
        child: dataRow, padding: EdgeInsets.all(5.0),
      );

      List<GestureDetector> leftActions = List<GestureDetector>();
      if(widget.callbackLeft!=null){
        leftActions.add(GestureDetector(
          onTap: (){
            widget.callbackLeft.callback;
          },
          child: Text(widget.callbackLeft.title),
        ));
      }

      List<GestureDetector> rightActions = List<GestureDetector>();
      if(widget.callbackRight!=null){
        rightActions.add(GestureDetector(
          onTap: (){
            widget.callbackRight.callback;
          },
          child: Text(widget.callbackRight.title),
        ));
      }

      Slidable slidable = Slidable(
        controller: slidableController,
        delegate: SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child:  Container(
          color: Colors.white,
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

class ResultsDataSource extends DataTableSource {
  final List<RowObject> _results;

  ResultsDataSource(this._results);

  void _sort<T>(Comparable<T> getField(RowObject d), bool ascending) {
    _results.sort((RowObject a, RowObject b) {
      if (!ascending) {
        final RowObject c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _results.length) return null;
    final RowObject result = _results[index];
    return DataRow.byIndex(
        index: index,
        selected: result.selected,
        onSelectChanged: (bool value) {
          if (result.selected != value) {
            _selectedCount += value ? 1 : -1;
            assert(_selectedCount >= 0);
            result.selected = value;
            notifyListeners();
          }
        },
        cells: <DataCell>[
          DataCell(Text('${result.location}')),
          DataCell(Text('${result.type}')),
          DataCell(Text('${result.status}')),
          DataCell(Text('${result.user}')),
          DataCell(Text('${result.type}')),
        ]);
  }

  @override
  int get rowCount => _results.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;




  //later
//  void _selectAll(bool checked) {
//    for (RowObject result in _results)
//      result.selected = checked;
//    _selectedCount = checked ? _results.length : 0;
//    notifyListeners();
//  }

//  void _sort<T>(
//      Comparable<T> getField(RowObject d), int columnIndex, bool ascending) {
//    _resultsDataSource._sort<T>(getField, ascending);
//    setState(() {
//      _sortColumnIndex = columnIndex;
//      _sortAscending = ascending;
//    });
//  }



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