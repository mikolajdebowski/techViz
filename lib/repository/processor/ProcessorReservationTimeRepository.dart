import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorReservationTimeRepository implements IRemoteRepository<UserStatus>{

  @override
  Future fetch() {
    print('Fetching '+ toString());

    Completer _completer = Completer<void>();
    SessionClient client = SessionClient();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_USER_STATUS.toString()).id;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).then((String rawResult) async {


      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      LocalRepository localRepo = LocalRepository();
      await localRepo.open();

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = <String, dynamic>{};
        map['UserStatusID'] = values[_columnNames.indexOf("UserStatusID")];
        map['Description'] = values[_columnNames.indexOf("UserStatusName")];
        map['IsOnline'] = values[_columnNames.indexOf("IsOnline")];
        localRepo.insert('UserStatus', map);
      });

      _completer.complete();

    }).catchError((dynamic e){
      print(e.toString());
      _completer.completeError(e);
    });

    return _completer.future;
  }
}