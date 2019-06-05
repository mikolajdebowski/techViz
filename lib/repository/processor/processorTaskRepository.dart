import 'dart:async';
import 'dart:convert';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

import 'exception/invalidResponseException.dart';

class ProcessorTaskRepository implements ITaskRemoteRepository{
  IProcessorRepositoryConfig config;

  ProcessorTaskRepository(this.config);

  @override
  Future<dynamic> fetch()  {
    const String tag = 'TECHVIZ_MOBILE_TASK';
    print('Fetching '+ tag);

    Completer _completer = Completer<List<Map<String, dynamic>>>();
    String url = config.GetURL(tag);

    SessionClient().get(url).then((String rawResult) async{
      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;

      List<String> _columnNames = (decoded['ColumnNames'] as String).split(',');

      List<Map<String, dynamic>> listToReturn =  <Map<String, dynamic>>[];

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = <String, dynamic>{};
        map['_ID'] = values[_columnNames.indexOf("_ID")] as String;
        map['_VERSION'] = values[_columnNames.indexOf("_Version")] as String;
        map['USERID'] = values[_columnNames.indexOf("UserID")] as String;
        map['_DIRTY'] = false;
        map['MACHINEID'] = values[_columnNames.indexOf("MachineID")];
        map['LOCATION'] = values[_columnNames.indexOf("Location")];
        map['TASKSTATUSID'] = values[_columnNames.indexOf("TaskStatusID")];
        map['TASKTYPEID'] = values[_columnNames.indexOf("TaskTypeID")];
        map['TASKURGENCYID'] = values[_columnNames.indexOf("TaskUrgencyID")];

        DateTime dateCreated = DateTime.parse(values[_columnNames.indexOf("TaskCreated")].toString());
        map['TASKCREATED'] = dateCreated.toString();

        DateTime dateAssigned = DateTime.parse(values[_columnNames.indexOf("TaskAssigned")].toString());
        map['TASKASSIGNED'] = dateAssigned.toString();

        map['PLAYERID'] = values[_columnNames.indexOf("PlayerID")];
        map['AMOUNT'] = values[_columnNames.indexOf("Amount")] == '' ? 0.0 : values[_columnNames.indexOf("Amount")];
        map['EVENTDESC'] = values[_columnNames.indexOf("EventDesc")];
        map['PLAYERFIRSTNAME'] = values[_columnNames.indexOf("FirstName")];
        map['PLAYERLASTNAME'] = values[_columnNames.indexOf("LastName")];
        map['PLAYERTIER'] = values[_columnNames.indexOf("Tier")];
        map['PLAYERTIERCOLORHEX'] = values[_columnNames.indexOf("TierColorHex")];

        listToReturn.add(map);
      });
      _completer.complete(listToReturn);

    }).catchError((dynamic onError){
      _completer.completeError(InvalidResponseException(onError));
    });
    return _completer.future;
  }

  @override
  Future openTasksSummary() async {
    const String tag = 'TECHVIZ_MOBILE_TASK_SUMMARY';
    print('Fetching $tag');

    Completer<dynamic> _completer = Completer<dynamic>();
    String url = config.GetURL(tag);

    SessionClient().get(url).then((String rawResult) async {

      List<Map<String, dynamic>> listToReturn =  <Map<String, dynamic>>[];

      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;
      List<String> _columnNames = (decoded['ColumnNames'] as String).split(',');
      rows.forEach((dynamic d) {

        dynamic values = d['Values'];
        Map<String, dynamic> mapEntry = <String, dynamic>{};
        mapEntry['_ID'] = values[_columnNames.indexOf("_ID")];
        mapEntry['Location'] = values[_columnNames.indexOf("Location")];
        mapEntry['TaskTypeID'] = values[_columnNames.indexOf("TaskTypeID")];
        mapEntry['TaskStatusID'] = values[_columnNames.indexOf("TaskStatusID")];
        mapEntry['UserID'] = values[_columnNames.indexOf("UserID")];
        mapEntry['ElapsedTime'] = values[_columnNames.indexOf("ElapsedTime")];

        mapEntry['TaskUrgencyID'] = values[_columnNames.indexOf("TaskUrgencyID")];
        mapEntry['ParentID'] = values[_columnNames.indexOf("ParentID")];
        mapEntry['IsTechTask'] = values[_columnNames.indexOf("IsTechTask")];

        listToReturn.add(mapEntry);
      });

      _completer.complete(listToReturn);

    }).catchError((dynamic e){
      _completer.completeError(InvalidResponseException(e));
    });
    return _completer.future;
  }
}