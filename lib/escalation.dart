import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/presenter/escalationPathPresenter.dart';

typedef OnEscalationResult = void Function(bool result);

class EscalationForm extends StatefulWidget {
  final String _taskID;
  final String _taskLocation;
  final OnEscalationResult onEscalationResult;

  EscalationForm(this._taskID, this._taskLocation, this.onEscalationResult);

  @override
  State<StatefulWidget> createState() => EscalationFormState();
}

class EscalationFormState extends State<EscalationForm> implements IEscalationPathPresenter {
  List<EscalationPath> _escalationPathList;
  List<TaskType> _taskTypeList;

  EscalationPath _escalationPathSelected;
  TaskType _taskTypeSelected;
  EscalationPathPresenter _presenter;
  ScrollController _scrollController;
  TextEditingController _notesController;
  bool _btnDisabled = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _presenter = EscalationPathPresenter(this);
    _presenter.loadEscalationPath();
    _presenter.loadTaskType();

    _scrollController = ScrollController();
    _notesController = TextEditingController();

    super.initState();
  }

  //PRESENTER
  @override
  void onEscalationPathLoaded(List<EscalationPath> escalationPathList) {
    setState(() {
      print(escalationPathList.length);
      _escalationPathList = escalationPathList;
    });
  }

  @override
  void onTaskTypeLoaded(List<TaskType> taskTypeList) {
    setState(() {
      _taskTypeList = taskTypeList;
    });
  }

  @override
  void onEscalated() {
    widget.onEscalationResult(true);
    Navigator.of(context).pop();
  }

  @override
  void onLoadError(dynamic error) {
    print(error);

    setState(() {
      _btnDisabled = true;
    });
  }

  //VIEW
  bool get taskTypeRequired {
    return _escalationPathSelected != null && (_escalationPathSelected.id == 2 || _escalationPathSelected.id == 3);
  }

  @override
  Widget build(BuildContext context) {


    Container container = Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
        child: SingleChildScrollView(
            controller: _scrollController,
            child: Form(

                key: _formKey,
                child: formWidget())));

    VizButton okBtn = VizButton(title: 'OK', highlighted: true, onTap: () {

      if(_btnDisabled)
        return;

      if(_formKey.currentState.validate()) {
        setState(() {
          _btnDisabled = true;
        });
        _presenter.escalateTask(widget._taskID, _escalationPathSelected, taskType: taskTypeRequired? _taskTypeSelected: null, notes: _notesController.text);
      }
    });
    ActionBar ab = ActionBar(title: 'Escalate task ${widget._taskLocation}', tailWidget: okBtn, onCustomBackButtonActionTapped: (){
      widget.onEscalationResult(true);
    });
    return Scaffold(backgroundColor: Colors.black, appBar: ab, body: SafeArea(child: container),);
  }

  Widget formWidget() {
    if (_escalationPathList == null) {
      return Center(
        child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()),
      );
    }

    List<Widget> items = List<Widget>();

    //ESCALATION PATH
    FormField escalationPathFormField = FormField<EscalationPath>(
      validator: (value) {
        if (value == null)
          return 'Select Escalation Path';
      },
      builder: (FormFieldState<EscalationPath> state) {
        return InputDecorator(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: 10.0),
              isDense: true,
              icon: Icon(Icons.trending_up),
              labelText: 'Escalation Path',
            ),
            isEmpty: _escalationPathSelected == null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonHideUnderline(
                    child: DropdownButton<EscalationPath>(
                      isDense: true,
                      isExpanded: true,
                      value: _escalationPathSelected,
                      onChanged: (EscalationPath newValue) {
                        state.didChange(newValue);
                        setState(() {
                          _escalationPathSelected = newValue;
                        });
                      },
                      items: _escalationPathList.map((EscalationPath ep) {
                        return DropdownMenuItem<EscalationPath>(
                          value: ep,
                          child: Text(ep.description),
                        );
                      }).toList(),
                    )),
                Text(
                  state.hasError ? state.errorText : '',
                  style:
                  TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
                )
              ],
            ),
            );
      },
    );

    items.add(Padding(padding: EdgeInsets.only(left: 10, right: 10), child: escalationPathFormField));

    //TASKTYPE
    if (taskTypeRequired) {

      FormField taskTypeFormField = FormField<TaskType>(

        validator: (value) {
          if (taskTypeRequired && value == null)
            return 'Select Task Type';
        },
        builder: (FormFieldState<TaskType> state) {
          return InputDecorator(
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.only(top: 10.0),
                icon: Icon(Icons.sort),
                labelText: 'Task Type',
              ),
              isEmpty: _taskTypeSelected == null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DropdownButtonHideUnderline(
                      child: DropdownButton<TaskType>(
                        isDense: true,
                        isExpanded: true,
                        value: _taskTypeSelected,
                        onChanged: (TaskType newValue) {
                          state.didChange(newValue);
                          setState(() {
                            _taskTypeSelected = newValue;
                          });
                        },
                        items: _taskTypeList.map((TaskType tt) {
                          return DropdownMenuItem<TaskType>(
                            value: tt,
                            child: Text(tt.description),
                          );
                        }).toList(),
                      )),
                  Text(
                    state.hasError ? state.errorText : '',
                    style:
                    TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
                  )
                ],
              ));
        },
      );

      items.add(Padding(padding: EdgeInsets.only(left: 10, right: 10), child: taskTypeFormField));
    }

    FormField<String> notesFormField = FormField<String>(builder: (FormFieldState<String> state) {
      return TextFormField(
          maxLength: 4000,
          maxLines: 3,
          controller: _notesController,
          textInputAction: TextInputAction.done,
          cursorColor: const Color(0xFF424242),
          decoration: const InputDecoration(
            labelStyle: TextStyle(color: const Color(0xFF424242)),
            isDense: true,
            focusedBorder: null,
            icon: Icon(Icons.note_add, color: const Color(0xFF424242)),
            labelText: 'Notes',
          ));
    });

    items.add(Padding(padding: EdgeInsets.only(left: 10, right: 10), child: notesFormField));

    return Column(
      children: items,
    );
  }


}
