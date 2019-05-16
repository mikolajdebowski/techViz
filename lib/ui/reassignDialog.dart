import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/vizDialog.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/presenter/reassignPresenter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
  final TextEditingController _typeUserController = TextEditingController();

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

    TypeAheadField typeUser = TypeAheadField<User>(

      noItemsFoundBuilder: (BuildContext context){
        return Padding(padding: EdgeInsets.all(10), child: Text('No users found'));
      },
      textFieldConfiguration: TextFieldConfiguration<User>(
        controller: this._typeUserController,
          autofocus: true
      ),
      suggestionsCallback: (String pattern) async {
        pattern = pattern.toLowerCase();
        return _userList.where((User user)=> user.userName.toLowerCase().contains(pattern) || user.userID.toLowerCase().contains(pattern)).toList();
      },
      itemBuilder: (context, User suggestion) {
        return ListTile(
          dense: true,
          title: Text(suggestion.userID),
          subtitle: Text('${suggestion.userName}'),
        );
      },
      onSuggestionSelected: (User suggestion) {
        setState(() {
          this._typeUserController.text = suggestion.userID;
          this._selectedValue = suggestion.userID;
        });
      },
    );

    Column contanteContainer = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Select the user to re-assign this task:'),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: typeUser,
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
