import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:techviz/components/VizAlert.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/model/reservationTime.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/SlotMachineRepository.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/reservationTimeRepository.dart';
import 'package:techviz/repository/session.dart';

class SlotLookup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SlotLookupState();
}

class SlotLookupState extends State<SlotLookup> {
  bool loading = true;

  final FocusNode _txtSearchFocusNode = FocusNode();
  final TextEditingController _txtSearchController = TextEditingController();
  SlotMachineRepository _repository = Repository().slotMachineRepository;
  String _searchKey = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _txtSearchController.addListener(_searchDispatch);
    _repository.fetch().then((dynamic fool) {
      setState(() {
        loading = false;
        _repository.listenAsync();
      });
    }).catchError((dynamic error) {
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


  void _showReservationCancelDialog(final BuildContext ctx, SlotMachine slotMachine){
    bool _isReserved = slotMachine.machineStatusID != '1';
    if (_isReserved) return;

    bool btnEnabled = true;

    showDialog<bool>(context: ctx, builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: Text('Cancel reservation'),
        content: Text("Cancel reservation for ${slotMachine.standID}?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              if(!btnEnabled) return;
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text("Yes"),
            onPressed: () {
              if(!btnEnabled) return;

              final Flushbar _loadingBar = VizDialog.LoadingBar(message: 'Cancelling...');
              _loadingBar.show(ctx);
              btnEnabled = false;
              _repository.cancelReservation(slotMachine.standID).then((dynamic result){
                _loadingBar.dismiss();
                Navigator.of(context).pop();
              }).whenComplete((){
                _loadingBar.dismiss();
                btnEnabled = true;
              });
            },
          )
        ],
      );
    });
  }

  void _showReservationPanel(final BuildContext ctx, SlotMachine slotMachine) async {
    ReservationTimeRepository _repo = Repository().reservationTimeRepository;
    List<ReservationTime> times = await _repo.getAll();

    bool _isOnlineForReservation = slotMachine.machineStatusID != '3';
    if (_isOnlineForReservation) return;

    final _formKey = GlobalKey<FormState>();
    bool _btnEnabled = true;

    final _txtControllerPlayerID = TextEditingController();
    String _ddbTimeReservation = times[0].key.toString();

    Widget _btnCreateReservation = OutlineButton(
        child: Text('Reserve'),
        onPressed: () {
          if(!_btnEnabled) return;

          if (_formKey.currentState.validate()) {

            _btnEnabled = false;
            final Flushbar _loadingBar = VizDialog.LoadingBar(message: 'Creating reservation...');
            _loadingBar.show(ctx);

            Session session = Session();
            _repository.setReservation(session.user.UserID, slotMachine.standID, _txtControllerPlayerID.text, _ddbTimeReservation).then((dynamic result){
              _loadingBar.dismiss();
              Navigator.of(ctx).pop();

            }).whenComplete((){
              _btnEnabled = true;
            });
          }
        });

    Widget _header = Container(
      height: 30.0,
      color: Colors.blue,
      child: Stack(
        children: <Widget>[Center(child: Text('Reservation'))],
      ),
    );

    Widget _innerForm = Expanded(
        child: Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                InputDecorator(
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_on),
                    labelText: 'Stand ID',
                  ),
                  child: Padding(padding: EdgeInsets.only(top: 5.0), child: Text('${slotMachine.standID}')),
                ),
                FormField<String>(builder: (FormFieldState<String> state) {
                  return TextFormField(
                      controller: _txtControllerPlayerID,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter> [
                        WhitelistingTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter Player ID';
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: 'Player ID',
                      ));
                }),
                FormField<String>(
                  initialValue: _ddbTimeReservation,
                  validator: (String value) {
                    if (value == null) return 'Select the time of reservation';
                  },
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                        decoration: InputDecoration(
                          icon: Icon(Icons.timer),
                          labelText: 'Time of reservation',
                        ),
                        isEmpty: _ddbTimeReservation == null,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _ddbTimeReservation,
                            isDense: true,
                            elevation: 2,
                            onChanged: (String newValue) {
                              setState(() {
                                _ddbTimeReservation = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: times.map((ReservationTime value) {
                              return DropdownMenuItem<String>(
                                value: value.key.toString(),
                                child: Text(value.value),
                              );
                            }).toList(),
                          ),
                        ));
                  },
                )
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: _btnCreateReservation,
          ),
        )
      ],
    ));

    showBottomSheet<void>(
        context: ctx,
        builder: (BuilderContext) {
          return Container(
            color: Color(0xAAeef5f5),
            child: Column(
              children: <Widget>[_header, _innerForm],
            ),
          );
        });
  }

  Image getIconForMachineStatus(String statusID) {
    String iconName;
    switch (statusID) {
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
        builder: (BuildContext context, AsyncSnapshot<List<SlotMachine>> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          var data = snapshot.data;

          if (_searchKey != null && _searchKey.length > 0) {
            data = data.where((SlotMachine sm) => sm.standID.contains(_searchKey) || sm.machineTypeName.toLowerCase().contains(_searchKey.toLowerCase())).toList();
          }

          return ListView.builder(
              itemCount: data == null ? 0 : data.length,
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
                      child: GestureDetector(
                        onTap: () {
                          if(slot.machineStatusID == '3')
                            _showReservationPanel(context, slot);
                          else if(slot.machineStatusID == '1')
                          _showReservationCancelDialog(context, slot);
                        },
                        child:
                            Container(height: rowHeight, padding: EdgeInsets.only(top: 5.0), decoration: even ? decorationEven : decorationOdd, child: getIconForMachineStatus(slot.machineStatusID)),
                      )),
                ]);
              });
        });

    var body = Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
      child: Column(
        children: <Widget>[header, Expanded(child: loading ? loadindIndicator : builder)],
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
}
