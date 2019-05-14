import 'dart:async';
import 'dart:core';
import 'package:techviz/repository/processor/processorLiveTable.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'dart:convert';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorUserSkillsRepository extends ProcessorLiveTable<dynamic> implements IRemoteRepository<dynamic>{

  @override
  Future fetch() async {

    print('Fetching '+this.toString());

    Completer _completer = Completer<void>();
    SessionClient client = SessionClient();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_USER_SKILLS.toString()).id;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).then((String rawResult) async {

      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;
      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      rows.forEach((dynamic d) {

        dynamic values = d['Values'];
        Map<String, dynamic> map = Map<String, dynamic>();
        map['SiteID'] = values[_columnNames.indexOf("SiteID")];
        map['SkillDescription'] = values[_columnNames.indexOf("SkillDescription")];
        map['UserID'] = values[_columnNames.indexOf("UserID")];
        map['UserRoleID'] = values[_columnNames.indexOf("UserRoleID")];
      });

      _completer.complete();

    }).catchError((dynamic e){
      print(e.toString());
      _completer.completeError(e);
    });


    return _completer.future;
  }


}