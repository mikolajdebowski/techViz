import 'dart:async';
import 'dart:convert';
import 'package:techviz/common/http/client/sessionClient.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import '../taskStatusRepository.dart';
import 'exception/invalidResponseException.dart';

class ProcessorTaskStatusRepository implements ITaskStatusRemoteRepository{
  IProcessorRepositoryConfig config;
  ProcessorTaskStatusRepository(this.config);

  @override
  Future fetch() {
    const String tag = 'TECHVIZ_MOBILE_TASK_STATUS';
    print('Fetching '+ tag);

    Completer _completer = Completer<List<Map<String, dynamic>>>();

    String url = config.GetURL(tag);
    SessionClient().get(url).then((String rawResult) async {
      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;
      List<String> _columnNames = (decoded['ColumnNames'] as String).split(',');

      List<Map<String, dynamic>> output = <Map<String, dynamic>>[];
      rows.forEach((dynamic d) {
        dynamic values = d['Values'];
        Map<String, dynamic> map = <String, dynamic>{};
        map['TaskStatusID'] = values[_columnNames.indexOf("TaskStatusID")];
        map['TaskStatusDescription'] = values[_columnNames.indexOf("TaskStatusDescription")];
        output.add(map);
      });
      _completer.complete(output);
    }).catchError((dynamic onError){
      _completer.completeError(InvalidResponseException(onError));
    });

    return _completer.future;
  }

}