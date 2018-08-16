import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/userRole.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/userRoleRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorUserRoleRepository extends UserRoleRepository{

  @override
  Future<List<dynamic>> fetch() {

    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_USER_ROLE.toString()).ID;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    return client.get(url).then((String rawResult) async {

      List<UserRole> _toReturn = List<UserRole>();
      Map<String,dynamic> decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'];

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      LocalRepository localRepo = LocalRepository();
      await localRepo.open();

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = Map<String, dynamic>();
        map['UserID'] = values[_columnNames.indexOf("UserID")];
        map['UserRoleID'] = values[_columnNames.indexOf("UserRoleID")];
        map['UserRoleName'] = values[_columnNames.indexOf("UserRoleName")];
        localRepo.insert('UserRole', map);
      });

      return Future.value(_toReturn);

    }).catchError((Error onError)
    {
      print(onError.toString());
    });
  }


}