import 'dart:async';
import 'dart:convert';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

import 'exception/invalidResponseException.dart';

class ProcessorUserRepository implements IUserRemoteRepository{
  IProcessorRepositoryConfig config;

  ProcessorUserRepository(this.config);
  @override
  Future<Map> fetch() {
    const String tag = 'TECHVIZ_MOBILE_USER';
    print('Fetching $tag');

    Completer _completer = Completer<Map>();
    String url = config.GetURL(tag);

    SessionClient().get(url).then((String rawResult) async {
      Map<String, dynamic> map = <String, dynamic>{};
      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;
      List<String> _columnNames = (decoded['ColumnNames'] as String).split(',');

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];
        map['UserID'] = values[_columnNames.indexOf("UserID")];
        map['UserRoleID'] = values[_columnNames.indexOf("UserRoleID")];
        map['UserName'] = values[_columnNames.indexOf("UserName")];
        map['UserStatusID'] = values[_columnNames.indexOf("UserStatusID")];
        map['StaffID'] = values[_columnNames.indexOf("StaffID")];
      });
      _completer.complete(map);

    }).catchError((dynamic e){
      _completer.completeError(InvalidResponseException(e));
    });
    return _completer.future;
  }

  @override
  Future<List<Map>> usersBySectionsByTaskCount() {
    const String tag = 'TECHVIZ_MOBILE_USERS_SECTIONS_TASKCOUNT';
    print('Fetching $tag');

    Completer _completer = Completer<List<Map>>();
    String url = config.GetURL(tag);

    SessionClient().get(url).then((String rawResult) async {
      List<Map<String, dynamic>> listToReturn =  <Map<String, dynamic>>[];
      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;
      List<String> _columnNames = (decoded['ColumnNames'] as String).split(',');
      rows.forEach((dynamic d) {

        dynamic values = d['Values'];

        Map<String, dynamic> mapEntry = <String, dynamic>{};
        mapEntry['UserID'] = values[_columnNames.indexOf("UserID")];
        mapEntry['UserName'] = values[_columnNames.indexOf("UserName")];
        mapEntry['SectionCount'] = values[_columnNames.indexOf("SectionCount")];
        mapEntry['TaskCount'] = values[_columnNames.indexOf("TaskCount7")];

        listToReturn.add(mapEntry);
      });
      _completer.complete(listToReturn);

    }).catchError((dynamic e){
      _completer.completeError(InvalidResponseException(e));
    });
    return _completer.future;
  }

  @override
  Future<List<Map>> teamAvailabilitySummary() {
    const String tag = 'TECHVIZ_MOBILE_TEAMAVAILABILITY_SUMMARY';
    print('Fetching $tag');

    Completer _completer = Completer<List<Map>>();
    String url = config.GetURL(tag);

    SessionClient().get(url).then((String rawResult) async {
      List<Map<String, dynamic>> listToReturn =  <Map<String, dynamic>>[];
      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;
      List<String> _columnNames = (decoded['ColumnNames'] as String).split(',');
      rows.forEach((dynamic d) {

        dynamic values = d['Values'];
        Map<String, dynamic> mapEntry = <String, dynamic>{};
        mapEntry['UserID'] = values[_columnNames.indexOf("UserID")];
        mapEntry['UserName'] = values[_columnNames.indexOf("UserName")];
        mapEntry['UserStatusID'] = values[_columnNames.indexOf("UserStatusID")];
        mapEntry['UserStatusName'] = values[_columnNames.indexOf("UserStatusName")];

        String strTaskCount7 = values[_columnNames.indexOf("TaskCount7")];
        String strSectionCount = values[_columnNames.indexOf("SectionCount")];

        mapEntry['TaskCount'] = strTaskCount7.isEmpty ? 0 : int.parse(strTaskCount7);
        mapEntry['SectionCount'] = strSectionCount.isEmpty ? 0 : int.parse(strSectionCount);

        listToReturn.add(mapEntry);
      });
      _completer.complete(listToReturn);

    }).catchError((dynamic e){
      _completer.completeError(e);
    });
    return _completer.future;
  }
}