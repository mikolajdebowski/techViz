import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/task.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class RestTaskRepository implements IRepository<Task>{

  var _columnNames = ["_ID","_Version","Amount","AnniversaryDate","Birthday","ElapsedTime","EscalationPath","EscalationTypeID","EventDesc","FirstName","LastName","Location","MachineID","PlayerID","TaskAssigned","TaskCreated","TaskNote","TaskReset","TaskResponded","TaskStatusID","TaskTypeID","TaskUrgency","Tier","UserID","PriorityScore"];

  @override
  Future<List<Task>> fetch() {

    SessionClient client = SessionClient.getInstance();

    return client.get('live/57bc13688a7-1613069bd49/57bc1368904-1613069bdb6/select.json').then((String rawResult) {

      List<Task> _toReturn = List<Task>();
      Map<String,dynamic> decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'];
      rows.forEach((dynamic d)
      {
        dynamic values = d['Values'];

        Task task = Task(
          id: values[_columnNames.indexOf("_ID")] as String,
          location: values[_columnNames.indexOf("Location")] as String,
        );

        _toReturn.add(task);

      });
      return Future.value(_toReturn);

    }).catchError((Error onError)
    {

    });
  }
}