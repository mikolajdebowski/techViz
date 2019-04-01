 import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/role.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorRoleRepository extends IRemoteRepository<Role>{

  @override
  Future fetch() {
    print('Fetching '+this.toString());

    Completer _completer = Completer<void>();
    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_ROLE.toString()).id;
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
        map['UserRoleID'] = values[_columnNames.indexOf("UserRoleID")];
        map['UserRoleName'] = values[_columnNames.indexOf("UserRoleName")];
        map['IsAttendant'] = values[_columnNames.indexOf("IsAttendant")];
        map['IsManager'] = values[_columnNames.indexOf("IsManager")];
        map['IsSupervisor'] = values[_columnNames.indexOf("IsSupervisor")];
        map['IsTechManager'] = values[_columnNames.indexOf("IsTechManager")];
        map['IsTechnician'] = values[_columnNames.indexOf("IsTechnician")];
        map['IsTechSupervisor'] = values[_columnNames.indexOf("IsTechSupervisor")];

        localRepo.insert('Role', map);
      });

      _completer.complete();

    }).catchError((dynamic e)
    {
      print(e.toString());
      _completer.completeError(e);
    });

    return _completer.future;
  }


}