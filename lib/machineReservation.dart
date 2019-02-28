import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/model/reservationTime.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/SlotMachineRepository.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/reservationTimeRepository.dart';
import 'package:techviz/repository/session.dart';

class MachineReservation extends StatefulWidget {
  final SlotMachine slotMachine;

  const MachineReservation({Key key, this.slotMachine}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MachineReservationState();
}

class MachineReservationState extends State<MachineReservation> {
  ReservationTimeRepository _reservationTimeRepo = Repository().reservationTimeRepository;
  SlotMachineRepository _slotMachineRepositoryRepo = Repository().slotMachineRepository;

  List<ReservationTime> times = [];
  final _formKey = GlobalKey<FormState>();
  final _txtControllerPlayerID = TextEditingController();
  String _ddbTimeReservation = "15";
  bool _btnEnabled = true;

  @override
  void initState() {
    // TODO: implement initState

    _reservationTimeRepo.getAll().then((List<ReservationTime> list) {
      setState(() {
        times = list;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _btnCreateReservation = OutlineButton(
        child: Text('Reserve'),
        onPressed: () {

          if (!_btnEnabled) return;
          if (_formKey.currentState.validate()) {
            _btnEnabled = false;
            final Flushbar _loadingBar = VizDialog.LoadingBar(message: 'Creating reservation...');
            _loadingBar.show(context);

            Session session = Session();
            _slotMachineRepositoryRepo.setReservation(session.user.UserID, widget.slotMachine.standID, _txtControllerPlayerID.text, _ddbTimeReservation).then((dynamic result) {
              _loadingBar.dismiss();
              Navigator.of(context).pop();
            }).whenComplete(() {
              _btnEnabled = true;
            });
          }
        });

    var body = Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFeef5f5), Color(0xFFeef5f5)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child:  Form(
            key: _formKey,

            child: Column(
              children: <Widget>[
                InputDecorator(
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_on),
                    labelText: 'Stand ID',
                  ),
                  child: Padding(padding: EdgeInsets.only(top: 5.0), child: Text('${widget.slotMachine.standID}')),
                ),
                FormField<String>(builder: (FormFieldState<String> state) {
                  return TextFormField(
                      controller: _txtControllerPlayerID,
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
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: _btnCreateReservation,
                  ),
                ),

              ],
            )
    )));

    return Scaffold(resizeToAvoidBottomPadding: false, backgroundColor: Colors.black, appBar: ActionBar(title: 'Reservation for ${widget.slotMachine.standID}'), body: SafeArea(child: body));
  }
}
