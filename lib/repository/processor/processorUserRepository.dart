import 'dart:async';
import 'dart:convert';

import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorUserRepository implements IUserRepository{

  @override
  Future fetch() {
    print('Fetching '+this.toString());

    Completer _completer = Completer<void>();
    SessionClient client = SessionClient();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_USER.toString()).id;
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
        map['UserID'] = values[_columnNames.indexOf("UserID")];
        map['UserRoleID'] = values[_columnNames.indexOf("UserRoleID")];
        map['UserName'] = values[_columnNames.indexOf("UserName")];
        map['UserStatusID'] = values[_columnNames.indexOf("UserStatusID")];
        map['StaffID'] = values[_columnNames.indexOf("StaffID")];

        localRepo.insert('User', map);
      });

      _completer.complete();

    }).catchError((dynamic e){
      print(e.toString());
      _completer.completeError(e);
    });


    return _completer.future;
  }

  @override
  Future allUsers() {
    String tag = 'TECHVIZ_MOBILE_USERS';
    print('Fetching $tag');

    Completer<List<Map<String, dynamic>>> _completer = Completer<List<Map<String, dynamic>>>();
    String url = ProcessorRepositoryConfig().GetURL(tag);

    SessionClient().get(url).then((String rawResult) async {
      List<Map<String, dynamic>> listToReturn =  List<Map<String, dynamic>>();
      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;
      List<String> _columnNames = (decoded['ColumnNames'] as String).split(',');
      rows.forEach((dynamic d) {

        dynamic values = d['Values'];

        Map<String, dynamic> mapEntry = Map<String, dynamic>();
        mapEntry['UserID'] = values[_columnNames.indexOf("UserID")];
        mapEntry['UserName'] = values[_columnNames.indexOf("UserName")];
        mapEntry['UserRoleID'] = values[_columnNames.indexOf("UserRoleID")];
        mapEntry['UserStatusID'] = values[_columnNames.indexOf("UserStatusID")];
        mapEntry['StaffID'] = values[_columnNames.indexOf("StaffID")];
        mapEntry['SiteID'] = values[_columnNames.indexOf("SiteID")];

        listToReturn.add(mapEntry);
      });
      _completer.complete(listToReturn);

    }).catchError((dynamic e){
      print(e.toString());
      _completer.completeError(e);
    });
    return _completer.future;
  }
}