import 'dart:async';
import 'dart:convert';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class RestTaskRepository extends TaskRepository {
  String liveTable = 'live/57bc13688a7-1613069bd49/57bc1368904-1613069bdb6/select.json';

  /**
   * fetch data from rest VizProcessor endpoint and store locally
   */

  @override
  Future<List<dynamic>> fetch()  {

    SessionClient client = SessionClient.getInstance();

    return client.get(liveTable).then((String rawResult) async{

      List<dynamic> _toReturn = List<dynamic>();

      Map<String,dynamic> decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'];

      var _columnNames = (decoded['ColumnNames'] as String).split(',');


      LocalRepository localRepo = LocalRepository();
      await localRepo.open();


      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = Map<String, dynamic>();
        map['_ID'] = values[_columnNames.indexOf("_ID")] as String;
        map['MachineID'] = values[_columnNames.indexOf("MachineID")];
        map['Location'] = values[_columnNames.indexOf("Location")];
        map['TaskStatusID'] = values[_columnNames.indexOf("TaskStatusID")];
        map['TaskTypeID'] = values[_columnNames.indexOf("TaskTypeID")];
        map['TaskCreated'] = values[_columnNames.indexOf("TaskCreated")];
        map['TaskAssigned'] = values[_columnNames.indexOf("TaskAssigned")];
        map['PlayerID'] = values[_columnNames.indexOf("PlayerID")];
        map['TaskNote'] = values[_columnNames.indexOf("TaskNote")];
        map['Amount'] = values[_columnNames.indexOf("Amount")];
        map['EventDesc'] = values[_columnNames.indexOf("EventDesc")];
        localRepo.insert('Task', map);
      });

      return Future.value(_toReturn);

    }).catchError((Error onError){
      print(onError.toString());
    });
  }








}