import 'dart:async';
import 'dart:convert';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorTaskRepository implements IRemoteRepository<Task>{

  /**
   * fetch data from rest VizProcessor endpoint and store locally
   */
  @override
  Future<dynamic> fetch()  {
    print('Fetching '+this.toString());

    Completer _completer = Completer<List<Map<String, dynamic>>>();
    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_TASK.toString()).id;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).then((String rawResult) async{
      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      List<Map<String, dynamic>> listToReturn =  List<Map<String, dynamic>>();

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = Map<String, dynamic>();
        map['_ID'] = values[_columnNames.indexOf("_ID")] as String;
        map['_VERSION'] = values[_columnNames.indexOf("_Version")] as String;
        map['USERID'] = values[_columnNames.indexOf("UserID")] as String;
        map['_DIRTY'] = false;
        map['MACHINEID'] = values[_columnNames.indexOf("MachineID")];
        map['LOCATION'] = values[_columnNames.indexOf("Location")];
        map['TASKSTATUSID'] = values[_columnNames.indexOf("TaskStatusID")];
        map['TASKTYPEID'] = values[_columnNames.indexOf("TaskTypeID")];
        map['TASKURGENCYID'] = values[_columnNames.indexOf("TaskUrgencyID")];



        var dateCreated = DateTime.parse(values[_columnNames.indexOf("TaskCreated")].toString());
        //var utcCreated = DateTime.utc(dateCreated.year, dateCreated.month, dateCreated.day, dateCreated.hour, dateCreated.minute, dateCreated.second, dateCreated.millisecond);
        map['TASKCREATED'] = dateCreated.toString();

        var dateAssigned = DateTime.parse(values[_columnNames.indexOf("TaskAssigned")].toString());
        //var utcAssigned = DateTime.utc(dateAssigned.year, dateAssigned.month, dateAssigned.day, dateAssigned.hour, dateAssigned.minute, dateAssigned.second, dateAssigned.millisecond);
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
      print(onError.toString());
      _completer.completeError(onError);
    });

    return _completer.future;
  }
}