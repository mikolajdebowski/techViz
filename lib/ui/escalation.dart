import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/form/vizDropDownFormField.dart';
import 'package:techviz/components/form/vizTextAreaFormField.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizSnackbar.dart';
import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/presenter/escalationPresenter.dart';

class EscalationForm extends StatefulWidget {
  final Task task;

  const EscalationForm(this.task);

  @override
  State<StatefulWidget> createState() => EscalationFormState(task);
}

class EscalationFormState extends State<EscalationForm> implements EscalationPresenterView {
  final EdgeInsets fieldPadding = EdgeInsets.only(left: 10, right: 10);

  Task _task;
  List<EscalationPath> _escalationPathList;
  List<TaskType> _taskTypeList;

  EscalationPath _escalationPathSelected;
  TaskType _taskTypeSelected;

  EscalationPresenter _presenter;
  TextEditingController _notesController;
  bool _btnDisabled = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _formFieldTaskTypeKey = GlobalKey<FormFieldState>();

  EscalationFormState(this._task);

  @override
  void initState() {
    _presenter = EscalationPresenter(this);
    _presenter.loadEscalationPath(_task.isTechTask);
    _presenter.loadTaskType();
    _notesController = TextEditingController();
    super.initState();
  }

  //PRESENTER
  @override
  void onEscalationPathLoaded(List<EscalationPath> escalationPathList) {
    setState(() {
      _escalationPathList = escalationPathList;
      if(_escalationPathList.length==1){
        _escalationPathSelected = _escalationPathList.first;
      }
    });
  }

  @override
  void onTaskTypeLoaded(List<TaskType> taskTypeList) {
    setState(() {
      _taskTypeList = taskTypeList;
    });
  }

  //VIEW
  bool get taskTypeRequired {
    return _escalationPathSelected != null &&
        (_escalationPathSelected.id == 2 || _escalationPathSelected.id == 3);
  }

  void onOKTap(){
    if (_btnDisabled)
      return;

    if(!_formKey.currentState.validate())
      return;


    final VizSnackbar snackbar = VizSnackbar.Processing('Escalating...');
    snackbar.show(context);

    setState(() {
      _btnDisabled = true;
    });

    String notes = _notesController.text.isNotEmpty ? base64.encode(utf8.encode(_notesController.text)): null;

    _presenter.escalateTask(
      _task.id,
        _escalationPathSelected,
        taskTypeRequired ? _taskTypeSelected : null,
        notes
    ).then((dynamic r){
      snackbar.dismiss();
      Navigator.of(context).pop(true);
    }).catchError((dynamic error){
      snackbar.dismiss();
      VizDialog.Alert(context, "Error", error.toString()).then((bool returned){
        Navigator.of(context).pop(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Container container = Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: const [Color(0xFF586676), Color(0xFF8B9EA7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                tileMode: TileMode.repeated)),
        child: SingleChildScrollView(
            child: Form(key: _formKey, child: formWidget)));

    VizButton okBtn = VizButton(
        title: 'OK',
        highlighted: true,
        onTap: onOKTap);

    ActionBar ab = ActionBar(
        title: 'Escalate Task ${_task.location}',
        tailWidget: okBtn,
        onCustomBackButtonActionTapped: () {
          Navigator.of(context).pop(false);
        });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ab,
      body: SafeArea(child: container),
    );
  }

  Widget get formWidget {
    if (_escalationPathList == null) {
      return Center(
        child: Padding(
            padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()),
      );
    }

    List<Widget> formFields = <Widget>[];
    VizDropdownFormField escalationPathFormField = VizDropdownFormField<EscalationPath>(
      validator: (EscalationPath value){
        if(value == null)
          return 'Select Escalation Path';
        return null;
      },
      onChanged: (EscalationPath newValue){
         setState(() {
            _escalationPathSelected = newValue;
            _taskTypeSelected = null;

            if(_formFieldTaskTypeKey.currentState!=null){
              _formFieldTaskTypeKey.currentState.reset();
            }
            _formKey.currentState.validate();
         });
      },
      leadingIcon: Icons.trending_up,
      labelText: 'Escalation path',
      initialValue: _escalationPathSelected,
      items: _escalationPathList.map((EscalationPath ep) {
          return DropdownMenuItem<EscalationPath>(
            value: ep,
            child: Text(ep.description),
          );
        }).toList(),
    );


    formFields.add(Padding(
        padding: fieldPadding,
        child: escalationPathFormField));

    //TASKTYPE
    if (taskTypeRequired) {
      VizDropdownFormField taskTypeFormField = VizDropdownFormField<TaskType>(
        key: _formFieldTaskTypeKey,
        validator: (TaskType value){
          if (taskTypeRequired && value == null)
            return 'Select a Task Type';
          return null;
        },
        onChanged: (TaskType newValue){
          setState(() {
            _taskTypeSelected = newValue;
            _formKey.currentState.validate();
          });
        },
        leadingIcon: Icons.sort,
        labelText: 'Task Type',
        initialValue: _taskTypeSelected,
        items: _taskTypeList.map((TaskType tt) {
          return DropdownMenuItem<TaskType>(
            value: tt,
            child: Text(tt.description),
          );
        }).toList(),
      );

      formFields.add(Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: taskTypeFormField));
    }

    VizTextAreaFormField notesFormField = VizTextAreaFormField(
        labelText: 'Notes',
        leadingIcon: Icons.note_add,
        textEditingController: _notesController);

    formFields.add(Padding(padding: fieldPadding, child: notesFormField));

    return Column(
      children: formFields,
    );
  }

}
