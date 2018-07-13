import 'dart:async';
import 'dart:convert';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/iTaskRepository.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class RestTaskRepository implements IRepository<dynamic>, ITaskRepository {
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
        map['ID'] = values[_columnNames.indexOf("_ID")] as String;
        map['Location'] = values[_columnNames.indexOf("Location")] as String;

        localRepo.insert('TASK', map);
      });

      return Future.value(_toReturn);

    }).catchError((Error onError){
      print(onError.toString());
    });
  }

  @override
  Future<List<Task>> getTaskList() async {
    LocalRepository localRepo = LocalRepository();
    await localRepo.open();

    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery('SELECT ID, location FROM TASK');

    List<Task> list = List<Task>();
    queryResult.forEach((Map<String, dynamic> task) {
      var t = Task(
        id: task['ID'] as String,
        location: task['Location'] as String,
      );
      list.add(t);
    });

    await localRepo.close();

    return list;
  }


  /**
   * fetch local task list
   */





}