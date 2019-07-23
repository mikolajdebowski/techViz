import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizSnackbar.dart';
import 'package:techviz/model/reservationTime.dart';
import 'package:techviz/repository/slotFloorRepository.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/reservationTimeRepository.dart';
import 'package:techviz/session.dart';

typedef OnMachineReservationResult = void Function(bool result);

class MachineReservation extends StatefulWidget {
  final String standID;

  const MachineReservation({Key key, this.standID}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MachineReservationState();
}

class MachineReservationState extends State<MachineReservation> {
  final ReservationTimeRepository _reservationTimeRepo = Repository().reservationTimeRepository;
  final SlotFloorRepository _slotMachineRepositoryRepo = Repository().slotFloorRepository;

  List<ReservationTime> times = [];
  final _formKey = GlobalKey<FormState>();
  final _txtControllerPlayerID = TextEditingController();
  String _ddbTimeReservation = "15";
  bool _btnEnabled = true;

  @override
  void initState() {
    super.initState();
    _reservationTimeRepo.getAll().then((List<ReservationTime> list) {
      setState(() {
        times = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SingleChildScrollView body = SingleChildScrollView(
        padding: EdgeInsets.all(0),
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                InputDecorator(
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_on, color: Colors.white),
                    labelText: 'StandID',
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Text(
                        '${widget.standID}',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                FormField<String>(builder: (FormFieldState<String> state) {
                  return TextFormField(
                      maxLength: 25,
                      controller: _txtControllerPlayerID,
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Please enter Player ID';
                        return null;
                      },
                      inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter(RegExp('[a-zA-Z0-9]'))],
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person, color: Colors.white),
                        labelText: 'Player ID',
                      ));
                }),
                FormField<String>(
                  initialValue: _ddbTimeReservation,
                  validator: (String value) {
                    if (value == null)
                      return 'Select the time of reservation';
                    return null;
                  },
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                        decoration: InputDecoration(
                          icon: Icon(Icons.timer, color: Colors.white),
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
                ),
              ],
            )));

    Container container = Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: const [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
        child: Padding(padding: EdgeInsets.all(5.0), child: body));

    VizButton okBtn = VizButton(
        title: 'OK',
        highlighted: true,
        onTap: () {
          if (!_btnEnabled)
            return;

          if (_formKey.currentState.validate()) {
            setState(() {
              _btnEnabled = false;
            });

            final VizSnackbar _snackbar = VizSnackbar.Loading('Creating reservation...');
            _snackbar.show(context);

            Session session = Session();
            _slotMachineRepositoryRepo
                .setReservation(session.user.userID, widget.standID, _txtControllerPlayerID.text, _ddbTimeReservation)
                .then((dynamic result) {
              _snackbar.dismiss();

              String reservationStatusId = result['reservationStatusId'].toString();

//              SlotMachine copy = widget.slotMachine;
//              copy.machineStatusID = reservationStatusId == '0' ? '1' : '3';
//              copy.updatedAt = DateTime.parse(result['sentAt'].toString());
//
//              _slotMachineRepositoryRepo.pushToController(copy, 'RESERVATION');

              dynamic toReturn = {'standID': widget.standID, 'reservationStatusID' : reservationStatusId == '0' ? '1' : '3', 'updatedAt' : DateTime.parse(result['sentAt'].toString())};

              Navigator.of(context).pop<dynamic>(toReturn);
            }).catchError((dynamic error) {
              VizDialog.Alert(context, 'Error', error.toString());
            }).whenComplete(() {
              _snackbar.dismiss();
              _btnEnabled = true;
            });
          }
        });

    ActionBar actionBar = ActionBar(
        title: 'Reservation for StandID ${widget.standID}',
        tailWidget: okBtn,
        onCustomBackButtonActionTapped: () {
          //widget.onEscalationResult(false);
        });

    Theme _theme = Theme(
      data: Theme.of(context).copyWith(
          canvasColor: Color(0xFF8B9EA7),
          inputDecorationTheme:
              InputDecorationTheme(
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black))),
          textTheme: TextTheme(
            body1: TextStyle(color: Colors.white),
          )),
      child: container,
    );

    return Scaffold(backgroundColor: Colors.black, appBar: actionBar, body: SafeArea(child: _theme));
  }
}
