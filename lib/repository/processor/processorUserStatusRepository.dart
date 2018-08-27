import 'dart:async';
import 'dart:convert';

import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/userStatusRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorUserStatusRepository extends UserStatusRepository{

  @override
  Future fetch() {
    Completer _completer = Completer<void>();
    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_USER_STATUS.toString()).ID;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).catchError((Error onError){
      print(onError.toString());
      _completer.completeError(onError);

    }).then((String rawResult) async {

      try{
        Map<String,dynamic> decoded = json.decode(rawResult);
        List<dynamic> rows = decoded['Rows'];

        var _columnNames = (decoded['ColumnNames'] as String).split(',');

        LocalRepository localRepo = LocalRepository();
        await localRepo.open();

        rows.forEach((dynamic d) {
          dynamic values = d['Values'];

          Map<String, dynamic> map = Map<String, dynamic>();
          map['UserStatusID'] = values[_columnNames.indexOf("LookupKey")];
          map['Description'] = values[_columnNames.indexOf("LookupValue")];
          map['IsOnline'] = values[_columnNames.indexOf("IsOnline")];
          localRepo.insert('UserStatus', map);
        });

        _completer.complete();
      }
      catch (e){
        print(e.toString());
        _completer.completeError(e);
      }
    });

    return _completer.future;
  }


}