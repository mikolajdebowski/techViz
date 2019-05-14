import 'dart:async';
import 'dart:convert';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorResponseParseError extends FormatException{
  String cause;
  ProcessorResponseParseError(){
    cause = 'Unable to parse vizprocessor response.';
  }
}

class ProcessorLiveTable<T> implements IRemoteRepository<T>{
  String tableID;

  @override
  Future fetch() {
    print('Fetching '+tableID);
    var _completer = Completer<dynamic>();

    SessionClient client = SessionClient();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(tableID).id;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).then((String rawResult) async{
      dynamic decoded = json.decode(rawResult);

      List<dynamic> _rows = decoded['Rows'] as List<dynamic>;
      List<String> _columnNames = (decoded['ColumnNames'] as String).split(',');

      return _completer.complete([_columnNames, _rows]);

    }).catchError((dynamic onError){
      print(onError.toString());
      if(onError.runtimeType == FormatException){
        _completer.completeError(ProcessorResponseParseError());
      }
      else
        _completer.completeError(onError);
    });

    return _completer.future;
  }
}