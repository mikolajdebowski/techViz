import 'dart:async';
import 'dart:convert';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorTaskRepository extends IRemoteRepository<Task>{

  /**
   * fetch data from rest VizProcessor endpoint and store locally
   */
  @override
  Future<dynamic> fetch()  {
    Completer _completer = Completer<List<Map<String, dynamic>>>();
    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_TASK.toString()).ID;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).catchError((Error onError){
      print(onError.toString());
      _completer.completeError(onError);
    }).then((String rawResult) async{
      Map<String,dynamic> decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'];

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      List<Map<String, dynamic>> listToReturn =  List<Map<String, dynamic>>();

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = Map<String, dynamic>();
        map['_ID'] = values[_columnNames.indexOf("_ID")] as String;
        map['_Version'] = values[_columnNames.indexOf("_Version")] as String;
        map['_Dirty'] = false;
        map['MachineID'] = values[_columnNames.indexOf("MachineID")];
        map['MachineID'] = values[_columnNames.indexOf("MachineID")];
        map['Location'] = values[_columnNames.indexOf("Location")];
        map['TaskStatusID'] = values[_columnNames.indexOf("TaskStatusID")];
        map['TaskTypeID'] = values[_columnNames.indexOf("TaskTypeID")];
        map['TaskCreated'] = values[_columnNames.indexOf("TaskCreated")];
        map['TaskAssigned'] = values[_columnNames.indexOf("TaskAssigned")];
        map['PlayerID'] = values[_columnNames.indexOf("PlayerID")];
        map['Amount'] = values[_columnNames.indexOf("Amount")] == '' ? 0.0 : values[_columnNames.indexOf("Amount")];
        map['EventDesc'] = values[_columnNames.indexOf("EventDesc")];
        map['PlayerID'] = values[_columnNames.indexOf("PlayerID")];
        map['PlayerFirstName'] = values[_columnNames.indexOf("FirstName")];
        map['PlayerLastName'] = values[_columnNames.indexOf("LastName")];
        map['PlayerTier'] = values[_columnNames.indexOf("Tier")];
        map['PlayerTierColorHex'] = values[_columnNames.indexOf("TierColorHex")];

        listToReturn.add(map);
      });
      _completer.complete(listToReturn);

    }).catchError((Error onError){
      print(onError.toString());
      _completer.completeError(onError);
    });

    return _completer.future;
  }
}