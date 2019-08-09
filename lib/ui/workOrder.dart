import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/form/vizDropDownFormField.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/components/vizSnackbar.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/presenter/workOrderPresenter.dart';

class WorkOrder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WorkOrderState();
}

class WorkOrderState extends State<WorkOrder> implements WorkOrderPresenterView{
  final DateFormat _formatDueDate = DateFormat("yyyy-MM-dd");
  WorkOrderPresenter _presenter;
  List<TaskType> _taskTypeList = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _mNumberController = TextEditingController();
  TaskType _selectedTaskType;

  @override
  void initState() {
    super.initState();
    _presenter = WorkOrderPresenter(this);
    _presenter.loadTaskType();
  }


  @override
  Widget build(BuildContext context) {
    TextFormField locationFormField = TextFormField(
      controller: _locationController,
      validator: (String value){
        return value.isEmpty && _mNumberController.value.text.isEmpty ? 'Location or Asset Number is required' : null;
      },
      maxLength: 10,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        isDense: true,
        icon: Icon(Icons.location_on, color: Colors.white),
        labelText: 'Location',
        hintText: '01-01-01',
      )
    );

    VizDropdownFormField typeFormField = VizDropdownFormField<TaskType>(
      labelText: 'Type',
      validator: (TaskType taskType){
        return taskType == null? 'Type is required' : null;
      },
      items: _taskTypeList.map((TaskType tt) {
        return DropdownMenuItem<TaskType>(
          value: tt,
          child: Text(tt.description),
        );
      }).toList(),
      leadingIcon: Icons.edit,
      onChanged: (TaskType taskType){
        setState(() {
          _selectedTaskType = taskType;
        });
      },
    );

    TextFormField assetNumberFormField = TextFormField(
      controller: _mNumberController,
      validator: (String value){
        return value.isEmpty && _locationController.value.text.isEmpty ? 'Asset Number or Location is required' : null;
      },
      textInputAction: TextInputAction.done,
      maxLength: 10,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        isDense: true,
        icon: Icon(Icons.confirmation_number, color: Colors.white),
        labelText: 'Asset Number',
        hintText: '12345',
      ),
    );

    TextFormField notesFormField = TextFormField(
      textInputAction: TextInputAction.done,
      maxLines: 3,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(isDense: true, labelText: 'Notes', icon: Icon(Icons.note, color: Colors.white)),
    );

    DateTimeField dueDateFormField = DateTimeField(
      decoration: InputDecoration(isDense: true, labelText: 'Due Date', icon: Icon(Icons.date_range, color: Colors.white)),
      format: _formatDueDate,
      style: TextStyle(color: Colors.white),
      onShowPicker: (context, currentValue) {
        return showDatePicker(
            context: context,
            firstDate: DateTime.now(),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2100));
      },
    );

    Form form = Form(
        key: _formKey,
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: const [Color(0xFF586676), Color(0xFF8B9EA7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    tileMode: TileMode.repeated)),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[locationFormField, typeFormField, assetNumberFormField, notesFormField, dueDateFormField],
              ),
            )));

    VizButton okBtn = VizButton(title: 'Save', highlighted: true, onTap: () {
        if(!_formKey.currentState.validate())
          return;

        final VizSnackbar _snackbar = VizSnackbar.Processing('Creating Work Order...');
        _snackbar.show(context);

        _presenter.create(_selectedTaskType).then((dynamic d){
          _snackbar.dismiss();
        }).catchError((dynamic error){
          _snackbar.dismiss();
          VizDialog.Alert(context, 'Error', error.toString());
        });
    });

    return Scaffold(
      appBar: ActionBar(title: 'Create Work Order', tailWidget: okBtn),
      body: SafeArea(child: SingleChildScrollView(child: Theme(
        data: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Color(0x66FFFFFF)),
          ),
        ),
        child: form,
      ))),
    );
  }

  @override
  void onTaskTypeLoaded(List<TaskType> taskTypeList) {
    setState(() {
      _taskTypeList = taskTypeList;
    });
  }

}
