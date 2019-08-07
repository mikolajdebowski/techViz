import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/vizActionBar.dart';

class WorkOrder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WorkOrderState();
}

class WorkOrderState extends State<WorkOrder> {
  bool _formOK;
  DateTime _selectedDueDate;


  String get selectedDueDate{
    return _selectedDueDate.toString();
  }

  Future<void> _showDueDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDueDate,
        firstDate: DateTime.now());
    if (picked != null && picked != _selectedDueDate)
      setState(() {
        _selectedDueDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    TextFormField locationFormField = TextFormField(
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        isDense: true,
        labelText: 'Location',
        hintText: '01-01-01',
      ),
    );

    TextFormField assetNumberFormField = TextFormField(
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        isDense: true,
        labelText: 'Asset Number',
        hintText: '12345',
      ),
    );

    TextFormField notesFormField = TextFormField(
      textInputAction: TextInputAction.done,
      maxLines: 3,
      decoration: InputDecoration(isDense: true, labelText: 'Notes'),
    );

    TextFormField dueDateFormField = TextFormField(
      readOnly: true,
      decoration: InputDecoration(isDense: true, labelText: 'Due Date'),
    );

    GestureDetector gestureForDueDate = GestureDetector(
      child: dueDateFormField,
      onTap: (){
        print('aa');
      },
    );

    Form form = Form(
        child: Container(
            constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
            color: Color(0xFFFFFFFF),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[locationFormField, assetNumberFormField, notesFormField, gestureForDueDate],
              ),
            )));


    VizButton okBtn = VizButton(title: 'Save', highlighted: true, enabled: _formOK);
    return Scaffold(
      appBar: ActionBar(title: 'Create Work Order', titleColor: Colors.blue, tailWidget: okBtn),
      body: SafeArea(child: SingleChildScrollView(child: form)),
    );
  }
}
