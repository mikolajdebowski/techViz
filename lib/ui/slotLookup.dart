import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:techviz/components/VizAlert.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/ui/machineReservation.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/slotFloorRepository.dart';
import 'package:techviz/repository/repository.dart';

class SlotFloor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SlotFloorState();
}

class SlotFloorState extends State<SlotFloor> with WidgetsBindingObserver {
  bool _loading;
  final double rowHeight = 45.0;
  final FocusNode _txtSearchFocusNode = FocusNode();
  final TextEditingController _txtSearchController = TextEditingController();
  final SlotFloorRepository _repository = Repository().slotFloorRepository;
  String _searchKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _txtSearchController.addListener(_searchDispatch);

    _loading = true;

    //this fetch pulls data from processor and pushs to the subject
    _repository.fetch().then((dynamic d){
      setState(() {
        _loading = false;
      });
      _repository.listenAsync();
    }).catchError((dynamic error) {
      _loading = false;
      VizAlert.Show(context, error.toString());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  void _showReservationView(final SlotMachine slot) {
    MachineReservation content = MachineReservation(standID: slot.standID);

    Navigator.push<dynamic>(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => content)).then((dynamic result){
      if(result==null)
        return;

      SlotMachine slotToPush = SlotMachine(
        standID: slot.standID,
        denom: slot.denom,
        machineTypeName: slot.machineTypeName,
        reservationTime: slot.reservationTime,
        updatedAt: result['updatedAt'],
        machineStatusID: result['reservationStatusId'] == '0' ? '1' : '3',
        machineStatusDescription: slot.machineStatusDescription,
        playerID: slot.playerID,
        dirty: true
      );

      _repository.updateLocalCache([slotToPush], 'RESERVATION');
    });
  }


  void _showReservationCancelDialog(SlotMachine slotMachine){
    bool _isReserved = slotMachine.machineStatusID != '1';
    if (_isReserved)
      return;

    showDialog<bool>(context: context, builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: Text('Cancel reservation'),
        content: Text("Cancel reservation for ${slotMachine.standID}?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text("Yes"),
            onPressed: () {

              Navigator.of(context).pop(true);
            },
          )
        ],
      );
    }).then((bool cancel){
      if(cancel){
        cancelReservation(slotMachine);
      }
    });
  }

  void cancelReservation(SlotMachine slotMachine){
    final Flushbar _loadingBar = VizDialog.LoadingBar(message: 'Cancelling reservation...');
    _loadingBar.show(context);

    _repository.cancelReservation(slotMachine.standID).then((dynamic result) {
      var reservationStatusId = result['reservationStatusId'].toString();
      var copy = slotMachine;
      copy.machineStatusID = reservationStatusId == '0' ? '1' : '3';
      copy.updatedAt = DateTime.parse(result['sentAt'].toString());
      copy.dirty = true;

      _repository.updateLocalCache([copy], 'CANCEL');

      _loadingBar.dismiss();
    }).catchError((dynamic error){
      _loadingBar.dismiss();
    });
  }

  Widget getIconForMachineStatus(String statusID, bool dirty) {
    if(dirty)
      return CircularProgressIndicator();

    String iconName;
    Color color;
    switch (statusID) {
      case "1":
        iconName = 'reserved';
        color = Colors.orange;
        break;
      case "2":
        iconName = 'inuse';
        color = null;
        break;
      case "3":
        iconName = 'available';
        color = Colors.green;
        break;
      default:
        iconName = 'offline';
        color = Colors.red;
        break;
    }
    return SizedBox(child: Image.asset("assets/images/ic_machine_$iconName.png", color: color), height: rowHeight*0.7,);
  }

  @override
  Widget build(BuildContext context) {
    Expanded searchComponent = Expanded(
        child: VizElevated(
            customWidget: Row(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(left: 5.0), child: ImageIcon(AssetImage("assets/images/ic_search.png"), size: 25.0)),
        Expanded(
            child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Colors.black),
                margin: EdgeInsets.only(left: 5.0, right: 5.0),
                padding: EdgeInsets.only(left: 10.0),
                child: TextField(
                    controller: _txtSearchController,
                    focusNode: _txtSearchFocusNode,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Search for standID or theme/game', hintStyle: TextStyle(color: Colors.white70)))))
      ],
    )));

    //LOADING INDICATOR
    Center loadindIndicator = Center(child: Center(child: CircularProgressIndicator()));

    Border borderColor = Border.all(color: Colors.white30, width: 0.5);

    //HEADER
    Row header = Row(
      children: <Widget>[
        headerColumn(1, 'StandID'),
        headerColumn(5, 'Theme'),
        headerColumn(1, 'Denom'),
        headerColumn(1, 'Status'),
      ],
    );

    //GRID STUFF
    TextStyle txtStyle = TextStyle(color: Colors.black54);
    BoxDecoration decorationEven = BoxDecoration(border: borderColor, color: Color(0xFFfafafa));
    BoxDecoration decorationOdd = BoxDecoration(border: borderColor, color: Color(0xFFeef5f5));

    NumberFormat formatCurrency = NumberFormat.simpleCurrency();

    StreamBuilder builder = StreamBuilder<List<SlotMachine>>(
        stream: _repository.slotMachineSubject.stream,
        builder: (BuildContext context, AsyncSnapshot<List<SlotMachine>> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var data = snapshot.data;

          if (_searchKey != null && _searchKey.isNotEmpty) {
            data = data.where((SlotMachine sm) => sm.standID.contains(_searchKey) || sm.machineTypeName.toLowerCase().contains(_searchKey.toLowerCase())).toList();
          }

          return ListView.builder(
              itemCount: data == null ? 0 : data.length,
              itemBuilder: (BuildContext context, int index) {
                var slot = data[index];
                var even = index % 2 == 0;

                Color customColor;
                if(slot.machineStatusID == '0')
                  customColor = Color(0x44FF0000);
                else if(slot.machineStatusID == '1')
                  customColor = Color(0x88FFFF00);
                else if(slot.machineStatusID == '2')
                  customColor = Color(0x8887CEEB);

                BoxDecoration decorationCustom;
                if(customColor!=null){
                  decorationCustom = BoxDecoration(border: borderColor, color: customColor);
                }
                else{
                  decorationCustom = even ? decorationEven : decorationOdd;
                }

                return Row(children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(top: 10.0),
                      decoration: decorationCustom,
                      height: rowHeight,
                      child: Text(slot.standID, style: txtStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.only(left: 5.0, top: 10.0),
                        height: rowHeight,
                        decoration: decorationCustom,
                        child: Text(slot.machineTypeName, style: txtStyle, overflow: TextOverflow.ellipsis),
                      )),
                  Expanded(
                      flex: 1,
                      child: Container(
                        height: rowHeight,
                        padding: EdgeInsets.only(top: 10.0),
                        decoration: decorationCustom,
                        child: Text(formatCurrency.format(slot.denom), style: txtStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                      )),
                  Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          if(slot.dirty)
                            return;

                          if(slot.machineStatusID == '3')
                            _showReservationView(slot);
                          else if(slot.machineStatusID == '1')
                            _showReservationCancelDialog(slot);
                        },
                        child: Container(decoration: decorationCustom, constraints: BoxConstraints.expand(height: rowHeight), child: Center(child: getIconForMachineStatus(slot.machineStatusID, slot.dirty)),),
                      )),
                ]);
              });
        });

    Container body = Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: const [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
      child: Column(
        children: <Widget>[header, Expanded(child: _loading ? loadindIndicator : Container(child: builder, color: Colors.white))],
      ),
    );

    return Scaffold(backgroundColor: Colors.black, appBar: ActionBar(centralWidgets: [searchComponent]), body: SafeArea(child: body));
  }

  Expanded headerColumn(int flex, String title) {
    Border borderColor = Border.all(color: Colors.grey, width: 0.5);
    BoxDecoration decorationHeader = BoxDecoration(border: borderColor, color: Color(0xFF505b6a));
    double rowHeight = 25.0;

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


}
