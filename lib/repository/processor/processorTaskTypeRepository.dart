import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorTaskTypeRepository extends IRemoteRepository<TaskType>{

  @override
  Future fetch() {
    print('Fetching '+this.toString());

    Completer _completer = Completer<void>();
    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_TASK_TYPE.toString()).ID;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).catchError((Error onError){
      print(onError.toString());
      _completer.completeError(onError);
    }).then((String rawResult) async {

      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      LocalRepository localRepo = LocalRepository();
      await localRepo.open();

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = Map<String, dynamic>();
        map['TaskTypeID'] = values[_columnNames.indexOf("TaskTypeID")];
        map['TaskTypeDescription'] = values[_columnNames.indexOf("TaskTypeDescription")];
        localRepo.insert('TaskType', map);
      });
      _completer.complete();

    }).catchError((Error e)
    {
      print(e.toString());
      _completer.completeError(e);
    });

    return _completer.future;
  }


}