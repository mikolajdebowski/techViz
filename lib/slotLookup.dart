import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:techviz/components/VizAlert.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/presenter/slotMachinePresenter.dart';
import 'package:techviz/repository/SlotMachineRepository.dart';
import 'package:techviz/repository/repository.dart';

class SlotLookup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SlotLookupState();
}

class SlotLookupState extends State<SlotLookup> implements ISlotMachinePresenter<SlotMachine> {
  SlotMachinePresenter slotMachinePresenter;
  bool loading = true;

  final FocusNode _txtSearchFocusNode = FocusNode();
  final TextEditingController _txtSearchController = TextEditingController();

  SlotMachineRepository _repository;
  String _searchKey = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    _txtSearchController.addListener(_searchDispatch);
    _repository = Repository().slotMachineRepository;
    _repository.fetch().then((dynamic fool){
      setState(() {
        loading = false;
        _repository.listenAsync();
      });
    }).catchError((dynamic error){
      loading = false;
      VizAlert.Show(context, error.toString());
    });
  }

  @override
  void dispose() {
    _txtSearchController.removeListener(_searchDispatch);
    _txtSearchController.dispose();

    _repository.cancelAsync();

    super.dispose();
  }

  void _searchDispatch() {
    setState(() {
      _searchKey = _txtSearchController.text;
    });
  }

  Image getIconForMachineStatus(String statusID){
    String iconName;
    switch(statusID){
      case "1":
        iconName = 'reserved';
        break;
      case "2":
        iconName = 'inuse';
        break;
      case "3":
        iconName = 'available';
        break;
      default:
        iconName = 'offline';
        break;
    }
    return Image.asset("assets/images/ic_machine_${iconName}.png", width: 100, height: 100);
  }

  @override
  Widget build(BuildContext context) {
    var searchComponent = Expanded(
        child: VizElevated(
          customWidget: Row(
            children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 10.0),child: ImageIcon(AssetImage("assets/images/ic_search.png"), size: 25.0)),
                Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius:BorderRadius.circular(5.0),
                        color: Colors.black
                      ),
                      margin: EdgeInsets.only(left: 10.0),
                      padding: EdgeInsets.only(left: 10.0),
                      child:
                      TextField(

                      controller: _txtSearchController,
                      focusNode: _txtSearchFocusNode,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Search for slots...', hintStyle: TextStyle(color: Colors.white70))))
                )
            ],
          )
        )
    );

    //LOADING INDICATOR
    var loadindIndicator = Center(child: Center(child: CircularProgressIndicator()));
    var rowHeight = 45.0;
    var borderColor = Border.all(color: Colors.white30, width: 0.5);

    //HEADER
    var header = Row(
      children: <Widget>[
        headerColumn(1, 'StandID'),
        headerColumn(5, 'Theme'),
        headerColumn(1, 'Denom'),
        headerColumn(1, 'Status'),
      ],
    );

    //GRID STUFF
    var txtStyle = TextStyle(color: Colors.black54);
    var decorationEven = BoxDecoration(border: borderColor, color: Color(0xFFfafafa));
    var decorationOdd = BoxDecoration(border: borderColor, color: Color(0xFFeef5f5));

    final formatCurrency = NumberFormat.simpleCurrency();

    var builder = StreamBuilder<List<SlotMachine>>(
      stream: _repository.stream,
      builder: (BuildContext context, AsyncSnapshot<List<SlotMachine>> snapshot){
        if(!snapshot.hasData)
          return CircularProgressIndicator();

        var data = snapshot.data;

        if(_searchKey!=null && _searchKey.length>0){
          data = data.where((SlotMachine sm) => sm.standID.contains(_searchKey) || sm.machineTypeName.toLowerCase().contains(_searchKey.toLowerCase())).toList();
        }

        return ListView.builder(
            itemCount: data==null? 0: data.length,
            itemBuilder: (BuildContext context, int index) {
              var slot = data[index];
              var even = index % 2 == 0;

              return Row(children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.only(top: 10.0),
                    decoration: even ? decorationEven : decorationOdd,
                    height: rowHeight,
                    child: Text(slot.standID, style: txtStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: Container(
                      padding: EdgeInsets.only(left: 5.0, top: 10.0),
                      height: rowHeight,
                      decoration: even ? decorationEven : decorationOdd,
                      child: Text(slot.machineTypeName, style: txtStyle, overflow: TextOverflow.ellipsis),
                    )),
                Expanded(
                    flex: 1,
                    child: Container(
                      height: rowHeight,
                      padding: EdgeInsets.only(top: 10.0),
                      decoration: even ? decorationEven : decorationOdd,
                      child: Text(formatCurrency.format(slot.denom), style: txtStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                    )),
                Expanded(
                    flex: 1,
                    child: Container(
                        height: rowHeight,
                        padding: EdgeInsets.only(top: 5.0),
                        decoration: even ? decorationEven : decorationOdd,
                        child: getIconForMachineStatus(slot.machineStatusID))),
                        //child: Text(slot.machineStatusID))),
              ]);
            });

      });

    var body = Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
      child: Column(
       children: <Widget>[
         header,
         Expanded(child: loading ? loadindIndicator: builder)
       ],
      ),
    );

    return Scaffold(backgroundColor: Colors.black, appBar: ActionBar(centralWidgets: [searchComponent]), body: SafeArea(child: body));
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
  void onLoadError(Error error) {
    print(error);
    Scaffold.of(context).showSnackBar( SnackBar(
      content: Text(error.toString()),
    ));
  }

  @override
  void onSlotMachinesLoaded(List<SlotMachine> result) {

//    if(slotsList==null && result!=null && result.length>0){
//      FocusScope.of(context).requestFocus(txtSearchFocusNode);
//    }

//    setState(() {
//      slotsList = result;
//      loading = false;
//    });
  }



}
