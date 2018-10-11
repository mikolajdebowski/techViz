import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:techviz/adapters/slotMachineAdapter.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/presenter/slotMachinePresenter.dart';

class SlotLookup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SlotLookupState();
}

class SlotLookupState extends State<SlotLookup> implements ISlotMachinePresenter<SlotMachine> {
  SlotMachinePresenter slotMachinePresenter;
  bool loading = true;
  List<SlotMachine> slotsList = List<SlotMachine>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    slotMachinePresenter = SlotMachinePresenter(this);
    slotMachinePresenter.load('');
  }

  Expanded headerColumn(int flex, String title) {
    var borderColor = Border.all(color: Colors.grey, width: 0.5);
    var decorationHeader = BoxDecoration(border: borderColor, color: Color(0xFF505b6a));
    var rowHeight = 25.0;

    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        decoration: decorationHeader,
        height: rowHeight,
        child: Text(title, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var searchComponent = <Widget>[
      Expanded(
        child: VizElevated(
            customWidget: Padding(
                padding: const EdgeInsets.all(5.0),
                child: TextField(
                    style: TextStyle(color: Colors.white70),
                    decoration: InputDecoration(isDense: true, hintText: 'Search for slots...', hintStyle: TextStyle(color: Colors.black54), icon: Icon(Icons.search, color: Colors.white70))))),
      ),
    ];

    //LOADING INDICATOR
    var loadindIndicator = Container(child: Center(child: CircularProgressIndicator()));
    var rowHeight = 40.0;
    var borderColor = Border.all(color: Colors.white30, width: 0.5);

    //HEADER
    var header = Row(
      children: <Widget>[
        headerColumn(1, 'Location'),
        headerColumn(5, 'Game'),
        headerColumn(1, ''),
        headerColumn(1, ''),
        headerColumn(1, 'Status'),
      ],
    );


    //GRID STUFF

    var txtStyle = TextStyle(color: Colors.black54);

    var decorationEven = BoxDecoration(border: borderColor, color: Color(0xFFfafafa));
    var decorationOdd = BoxDecoration(border: borderColor, color: Color(0xFFeef5f5));

    final formatCurrency = NumberFormat.simpleCurrency();


    var builder = ListView.builder(
        itemCount: slotsList.length,
        itemBuilder: (BuildContext context, int index) {
          var slot = slotsList[index];
          var even = index % 2 == 0;

          return Row(children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                decoration: even ? decorationEven : decorationOdd,
                height: rowHeight,
                child: Text(slot.standID, style: txtStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ),
            ),
            Expanded(
                flex: 5,
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  height: rowHeight,
                  decoration: even ? decorationEven : decorationOdd,
                  child: Text(slot.machineTypeName, style: txtStyle, overflow: TextOverflow.ellipsis),
                )),
            Expanded(
                flex: 1,
                child: Container(
                  height: rowHeight,
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  decoration: even ? decorationEven : decorationOdd,
                  child: Text(formatCurrency.format(slot.denom), style: txtStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                )),
            Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  height: rowHeight,
                  decoration: even ? decorationEven : decorationOdd,
                  child: Text('Reel', style: txtStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                )),
            Expanded(
                flex: 1,
                child: Container(
                    height: rowHeight,
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    decoration: even ? decorationEven : decorationOdd,
                    child: ImageIcon(AssetImage("assets/images/ic_search.png"), size: 15.0))),
          ]);
        });


    var body = Column(
      children: <Widget>[
        header,
        (loading ? loadindIndicator : Expanded(child: builder,))
      ],
    );

    return Scaffold(backgroundColor: Colors.black, appBar: ActionBar(centralWidgets: searchComponent), body: SafeArea(child: body, top: false, bottom: false));
  }

  @override
  void onLoadError(Error error) {
    // TODO: implement onLoadError
  }

  @override
  void onSlotMachinesLoaded(List<SlotMachine> result) {
    setState(() {
      slotsList = result;
      loading = false;
    });
  }
}
