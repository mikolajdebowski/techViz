import 'dart:async';
import 'dart:convert';

import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';


class ProcessorUserGeneralInfoRepository implements IRemoteRepository<dynamic>{

  @override
  Future fetch() {
    print('Fetching '+this.toString());

    Completer _completer = Completer<void>();
    SessionClient client = SessionClient();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_USER_GENERAL_INFO.toString()).id;
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
        map['Name'] = values[_columnNames.indexOf("Name")];
        map['StaffID'] = values[_columnNames.indexOf("StaffID")];
        map['UserName'] = values[_columnNames.indexOf("UserName")];
        map['UserRoleID'] = values[_columnNames.indexOf("UserRoleID")];

//          localRepo.insert('User', map);
      });

      _completer.complete();

    }).catchError((dynamic e){
      print(e.toString());
      _completer.completeError(e);
    });


    return _completer.future;
  }


}