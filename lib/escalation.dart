import 'package:flutter/material.dart';
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
  FocusNode _notesFocusNode;

  @override
  void initState() {
    _presenter = EscalationPathPresenter(this);
    _presenter.loadEscalationPath();
    _presenter.loadTaskType();

    _scrollController = ScrollController();
    _notesController = TextEditingController();
    _notesFocusNode = FocusNode();

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
  void onLoadError(dynamic error) {
    print(error);
  }

  //VIEW
  bool get shouldShowTaskTypeDropDown {
    return _escalationPathSelected != null && (_escalationPathSelected.id == 2 || _escalationPathSelected.id == 3);
  }

  @override
  Widget build(BuildContext context) {
    bool _btnDisabled = true;

    Container container = Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF586676), Color(0xFF8B9EA7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated)),
        child: SingleChildScrollView(
            controller: _scrollController,
            child: Form(
                child: Column(children: <Widget>[
              formWidget,
              Divider(
                color: Colors.grey,
                height: 4.0,
              )
            ]))));

    VizButton okBtn = VizButton(title: 'OK', highlighted: true, onTap: () {
      widget.onEscalationResult(false);
      Navigator.of(context).pop();
    });
    ActionBar ab = ActionBar(title: 'Escalate task ${widget._taskLocation}', tailWidget: okBtn, onCustomBackButtonActionTapped: (){
      widget.onEscalationResult(true);
    });
    return Scaffold(backgroundColor: Colors.black, appBar: ab, body: SafeArea(child: container),);
  }

  Widget get formWidget {
    if (_escalationPathList == null) {
      return Center(
        child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()),
      );
    }

    List<Widget> items = List<Widget>();

    //ESCALATION PATH
    FormField escalationPathFormField = FormField<EscalationPath>(
      initialValue: _escalationPathList.first,
      validator: (EscalationPath value) {
        if (value == null)
          return 'Select Escalation Path';
      },
      builder: (FormFieldState<EscalationPath> state) {
        return InputDecorator(
            decoration: InputDecoration(
              icon: Icon(Icons.trending_up),
              labelText: 'Escalation Path',
            ),
            isEmpty: _escalationPathSelected == null,
            child: DropdownButtonHideUnderline(
                child: DropdownButton<EscalationPath>(
                      value: _escalationPathSelected,
                      onChanged: (EscalationPath value) {
                        setState(() {
                          _escalationPathSelected = value;
                        });
                      },
                      items: _escalationPathList.map((EscalationPath ep) {
                        return DropdownMenuItem<EscalationPath>(
                          value: ep,
                          child: Text(ep.description),
                        );
                      }).toList(),
                    )));
      },
    );

    items.add(Padding(padding: EdgeInsets.only(left: 10, right: 10), child: escalationPathFormField));

    //TASKTYPE
    if (shouldShowTaskTypeDropDown) {

      FormField taskTypeFormField = FormField<TaskType>(
        initialValue: _taskTypeList.first,
        validator: (TaskType value) {
          if (value == null)
            return 'Select Task Type';
        },
        builder: (FormFieldState<TaskType> state) {
          return InputDecorator(
              decoration: InputDecoration(
                icon: Icon(Icons.sort),
                labelText: 'Task Type',
              ),
              isEmpty: _taskTypeSelected == null,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<TaskType>(
                    value: _taskTypeSelected,
                    onChanged: (TaskType value) {
                      setState(() {
                        _taskTypeSelected = value;
                      });
                    },
                    items: _taskTypeList.map((TaskType tt) {
                      return DropdownMenuItem<TaskType>(
                        value: tt,
                        child: Text(tt.description),
                      );
                    }).toList(),
                  )));
        },
      );

      items.add(Padding(padding: EdgeInsets.only(left: 10, right: 10), child: taskTypeFormField));
    }

    TextFormField tffNotes = TextFormField(
        focusNode: _notesFocusNode,
        controller: _notesController,
        maxLength: 4000,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: "Notes", enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 0.5))),
        maxLines: 3);

    items.add(Padding(padding: EdgeInsets.only(left: 10, right: 10), child: tffNotes));

    return Column(
      children: items,
    );
  }
}
