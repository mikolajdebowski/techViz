import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorTaskStatusRepository implements IRemoteRepository<TaskStatus>{

  @override
  Future fetch() {
    print('Fetching '+this.toString());

    Completer _completer = Completer<void>();
    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_TASK_STATUS.toString()).ID;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).then((String rawResult) async {

      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      LocalRepository localRepo = LocalRepository();
      await localRepo.open();

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = Map<String, dynamic>();
        map['TaskStatusID'] = values[_columnNames.indexOf("TaskStatusID")];
        map['TaskStatusDescription'] = values[_columnNames.indexOf("TaskStatusDescription")];
        localRepo.insert('TaskStatus', map);
      });

      _completer.complete();

    }).catchError((dynamic onError)
    {
      print(onError.toString());
      _completer.completeError(onError);
    });

    return _completer.future;
  }

}