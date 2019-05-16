import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/presenter/reassignPresenter.dart';

class ReassignDialog extends StatefulWidget {
  final String taskID;

  const ReassignDialog(this.taskID, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReassignDialogState();
}

class ReassignDialogState extends State<ReassignDialog> implements IReassignPresenter {
  String _selectedValue;
  List<User> _userList;
  ReassignPresenter _presenter;
  bool _processing = false;

  @override
  void initState() {
    super.initState();

    _presenter = ReassignPresenter(this);
    _presenter.loadUsers();
  }

  @override
  void onLoadError(dynamic error) {
    // TODO: implement onLoadError
  }

  @override
  void onUserLoaded(List<User> list) {
    setState(() {
      _userList = list;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_userList == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(),
        ),
      );
    }

    List<DropdownMenuItem<String>> listItems = List<DropdownMenuItem<String>>();

    _userList.forEach((User user) {
      listItems.add(DropdownMenuItem<String>(
        value: user.userID,
        child: Text(
          '${user.userName} (${user.userID})',
        ),
      ));
    });

    //TODO: CHANGE FOR AUTOCOMPLETE
    DropdownButton ddb = DropdownButton<String>(
      isExpanded: true,
      value: _selectedValue,
      items: listItems,
      onChanged: (value) {
        setState(() {
          _selectedValue = value;
        });
      },
      style: Theme.of(context).textTheme.title,
    );

    Column contanteContainer = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Select the user to re-assign this task:'),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: ddb,
        ),
      ],
    );

    return AlertDialog(
      title: Text('Re-assign task'),
      content: contanteContainer,
      actions: <Widget>[
        VizDialogButton('Cancel', () {
          Navigator.of(context).pop(false);
        }, highlighted: false, disabled: _processing == true),
        VizDialogButton('Re-assign', () {
          reassign();
        }, processing: _processing, disabled: _processing == true)
      ],
    );
  }

  void reassign() {
    if (_selectedValue == null) {
      return;
    }
    setState(() {
      _processing = true;
    });

    _presenter.reassign(widget.taskID, _selectedValue).then((dynamic result) {
      setState(() {
        _processing = false;
      });
      Navigator.of(context).pop(true);
    }).catchError((dynamic error){
      //TODO: HANDLE proper error message
      setState(() {
        _processing = false;
      });
    });
  }
}
