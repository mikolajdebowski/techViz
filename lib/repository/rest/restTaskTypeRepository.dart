import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class RestTaskTypeRepository implements IRepository<TaskType>{


  @override
  Future<List<TaskType>> fetch() {

    SessionClient client = SessionClient.getInstance();

    return client.get('live/57bc13688a7-1613069bd49/57bc13688d3-1613069bdb6/select.json').then((String rawResult) {

      List<TaskType> _toReturn = List<TaskType>();
      Map<String,dynamic> decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'];

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      rows.forEach((dynamic d)
      {
        dynamic values = d['Values'];

        TaskType taskType = TaskType(
            id: values[_columnNames.indexOf("LookupKey")] as String,
            description: values[_columnNames.indexOf("LookupValue")] as String
        );

        _toReturn.add(taskType);

      });
      return Future.value(_toReturn);

    }).catchError((Error onError)
    {
      print(onError.toString());
    });
  }


}