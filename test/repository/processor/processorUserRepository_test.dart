import 'dart:convert';

import 'package:http/src/response.dart';
import 'package:techviz/repository/processor/exception/invalidResponseException.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/processor/processorUserRepository.dart';
import 'package:test_api/test_api.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorClientMock implements IHttpClient{
  dynamic processorResponse;
  ProcessorClientMock(this.processorResponse);

  @override
  Future<String> auth(String user, String pwd) {
    throw UnimplementedError();
  }

  @override
  Future<Response> disconnect() {
    throw UnimplementedError();
  }

  @override
  Future<String> get(String url) {

    return Future<String>.value(jsonEncode(processorResponse));
  }
//
//  map['UserID'] = values[_columnNames.indexOf("UserID")];
//  map['UserRoleID'] = values[_columnNames.indexOf("UserRoleID")];
//  map['UserName'] = values[_columnNames.indexOf("UserName")];
//  map['UserStatusID'] = values[_columnNames.indexOf("UserStatusID")];
//  map['StaffID'] = values[_columnNames.indexOf("StaffID")];

  @override
  Future<String> post(String url, String body, {Map<String, String> headers}) {
    throw UnimplementedError();
  }
}

class ProcessorRepositoryConfigMock implements IProcessorRepositoryConfig{
  @override
  LiveTable GetLiveTable(String tagID) {
    return LiveTable('DUMMY_LIVETABLE', 'DUMMY_TAG');
  }

  @override
  String GetURL(String livetableTagID) {
    return 'DUMMY_URL_FOR_TESTING';
  }

  @override
  Future<void> Setup(SessionClient client) {
    throw UnimplementedError();
  }
}

void main(){
  ProcessorUserRepository mockRepository;

  test('fetch return irina instance', () async {
    dynamic result = {'ColumnNames': 'UserID,UserRoleID,UserName,UserStatusID,StaffID', 'Rows': [{'Values' : ['1','36248','Irina','10','10']}]};
    SessionClient().init(ProcessorClientMock(result));
    mockRepository = ProcessorUserRepository(ProcessorRepositoryConfigMock());

    dynamic expected = {
      'UserID': '1',
      'UserRoleID': '36248',
      'UserName': 'Irina',
      'UserStatusID': '10',
      'StaffID': '10'
    };

    expect(await mockRepository.fetch(), expected);
  });

  test('fetch should throw exception', () async {
    dynamic result = {'invalid json':'invalid json'};
    SessionClient().init(ProcessorClientMock(result));
    mockRepository = ProcessorUserRepository(ProcessorRepositoryConfigMock());

    try{
      await mockRepository.fetch();
      fail("exception not thrown");
    }
    catch(e){
      expect(e, isA<InvalidResponseException>());
    }
  });

  test('usersBySectionsByTaskCount should return list of users with sections count and tasks count', () async {
    dynamic result = {'ColumnNames': 'SectionCount,TaskCount7,UserID,UserName,UserStatusID', 'Rows': [{'Values' : ['1','1','irina','Irina','10']}]};
    SessionClient().init(ProcessorClientMock(result));
    mockRepository = ProcessorUserRepository(ProcessorRepositoryConfigMock());

    dynamic expected = [{
      'UserID': 'irina',
      'UserName': 'Irina',
      'SectionCount': '1',
      'TaskCount': '1'
    }];

    expect(await mockRepository.usersBySectionsByTaskCount(), expected);
  });

  test('usersBySectionsByTaskCount should throw exception due invalid json', () async {
    dynamic result = {'invalid json':'invalid json'};
    SessionClient().init(ProcessorClientMock(result));
    mockRepository = ProcessorUserRepository(ProcessorRepositoryConfigMock());

    try{
      await mockRepository.usersBySectionsByTaskCount();
      fail("exception not thrown");
    }
    catch(e){
      expect(e, isA<InvalidResponseException>());
    }
  });
}