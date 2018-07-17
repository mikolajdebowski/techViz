import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class RestTaskTypeRepository extends TaskTypeRepository{
  String liveTable = 'live/57bc13688a7-1613069bd49/57bc13688d3-1613069bdb6/select.json';

  @override
  Future<List<dynamic>> fetch() {

    SessionClient client = SessionClient.getInstance();

    return client.get(liveTable).then((String rawResult) async {

      List<TaskType> _toReturn = List<TaskType>();
      Map<String,dynamic> decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'];

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      LocalRepository localRepo = LocalRepository();
      await localRepo.open();

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = Map<String, dynamic>();
        map['_ID'] = values[_columnNames.indexOf("_ID")] as String;
        map['DefaultValue'] = values[_columnNames.indexOf("DefaultValue")] as String;
        map['LookupName'] = values[_columnNames.indexOf("LookupName")];
        map['TaskTypeID'] = values[_columnNames.indexOf("LookupKey")];
        map['TaskTypeDescription'] = values[_columnNames.indexOf("LookupValue")];
        localRepo.insert('TaskType', map);
      });

      return Future.value(_toReturn);

    }).catchError((Error onError)
    {
      print(onError.toString());
    });
  }


}