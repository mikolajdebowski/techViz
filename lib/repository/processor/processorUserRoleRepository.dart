import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/userRole.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorUserRoleRepository extends IRemoteRepository<UserRole>{

  @override
  Future fetch() {
    Completer _completer = Completer<void>();
    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_USER_ROLE.toString()).ID;
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

        print(rows.length);

        rows.forEach((dynamic d) {
          dynamic values = d['Values'];

          Map<String, dynamic> map = Map<String, dynamic>();
          map['UserID'] = values[_columnNames.indexOf("UserID")];
          map['UserRoleID'] = values[_columnNames.indexOf("UserRoleID")];
          localRepo.insert('UserRole', map);
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