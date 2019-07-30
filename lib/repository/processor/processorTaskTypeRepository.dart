import 'dart:async';
import 'dart:convert';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

import '../taskTypeRepository.dart';
import 'exception/invalidResponseException.dart';

class ProcessorTaskTypeRepository implements ITaskTypeRemoteRepository{
  IProcessorRepositoryConfig config;
  ProcessorTaskTypeRepository(this.config);

  @override
  Future fetch() {
    const String tag = 'TECHVIZ_MOBILE_TASK_TYPE';
    print('Fetching '+ tag);

    Completer _completer = Completer<List<Map<String,dynamic>>>();

    String url = config.GetURL(tag);
    SessionClient().get(url).then((String rawResult) async {

      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;
      List<String> _columnNames = (decoded['ColumnNames'] as String).split(',');

      List<Map<String, dynamic>> output = <Map<String, dynamic>>[];
      rows.forEach((dynamic d) {
        dynamic values = d['Values'];
        Map<String, dynamic> map = <String, dynamic>{};
        map['TaskTypeID'] = values[_columnNames.indexOf("TaskTypeID")];
        map['TaskTypeDescription'] = values[_columnNames.indexOf("TaskTypeDescription")];
        map['LookupName'] = values[_columnNames.indexOf("LookupName")];
        output.add(map);
      });
      _completer.complete(output);

    }).catchError((dynamic e)
    {
      _completer.completeError(InvalidResponseException(e));
    });
    return _completer.future;
  }
}