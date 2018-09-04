import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/role.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorRoleRepository extends IRemoteRepository<Role>{

  @override
  Future fetch() {
    Completer _completer = Completer<void>();
    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_ROLE.toString()).ID;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).catchError((Error onError){
      print(onError.toString());
      _completer.completeError(onError);

    }).then((String rawResult) async {
      Map<String,dynamic> decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'];

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      LocalRepository localRepo = LocalRepository();
      await localRepo.open();

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = Map<String, dynamic>();
        map['_ID'] = values[_columnNames.indexOf("_ID")] as String;
        map['UserRoleID'] = values[_columnNames.indexOf("LookupKey")];
        map['UserRoleName'] = values[_columnNames.indexOf("LookupValue")];
        localRepo.insert('Role', map);
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