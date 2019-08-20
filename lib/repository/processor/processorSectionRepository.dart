import 'dart:async';
import 'dart:convert';

import 'package:techviz/common/http/client/sessionClient.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/remoteRepository.dart';

class ProcessorSectionRepository implements IRemoteRepository<Role> {
  @override
  Future fetch() {
    print('Fetching '+ toString());

    Completer _completer = Completer<void>();
    SessionClient client = SessionClient();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_SECTION.toString()).id;
    String url = 'live/${config.DocumentID}/$liveTableID/select.json';

    client.get(url).then((String rawResult) async {
      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      LocalRepository localRepo = LocalRepository();
      await localRepo.open();

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        Map<String, dynamic> map = <String, dynamic>{};
        map['SectionID'] = values[_columnNames.indexOf("SectionID")];
        localRepo.insert('Section', map);
      });

      _completer.complete();
    }).catchError((dynamic e) {
      print(e.toString());
      _completer.completeError(e);
    });

    return _completer.future;
  }
}
