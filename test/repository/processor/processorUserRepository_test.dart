import 'package:techviz/common/http/client/sessionClient.dart';
import 'package:techviz/repository/processor/exception/invalidResponseException.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/processor/processorUserRepository.dart';
import 'package:test_api/test_api.dart';

import '../mock/processorClientMock.dart';

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


  test('fetch return irina instance', () async {
    dynamic result = {'ColumnNames': 'UserID,UserRoleID,UserName,UserStatusID,StaffID', 'Rows': [{'Values' : ['1','36248','Irina','10','10']}]};
    SessionClient().init(ProcessorClientMock(result));
    ProcessorUserRepository mockRepository = ProcessorUserRepository(ProcessorRepositoryConfigMock());

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
    ProcessorUserRepository mockRepository = ProcessorUserRepository(ProcessorRepositoryConfigMock());

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
    ProcessorUserRepository mockRepository = ProcessorUserRepository(ProcessorRepositoryConfigMock());

    dynamic expected = [{
      'UserID': 'irina',
      'UserName': 'Irina',
      'SectionCount': '1',
      'TaskCount': '1'
    }];

    expect(await mockRepository.usersBySectionsByTaskCount(), expected);
  });

  test('teamAvailabilitySummary should return two users', () async {
    dynamic result = {
        'ColumnNames': 'SectionCount,TaskCount7,UserID,UserName,UserStatusID,UserStatusName',
        'Rows': [
            {'Values' : ['4','2','irina','Irina','30', 'Working Task']},
            {'Values' : ['1','0','asmith','Angus Smith','30', 'Available']}
            ]
    };
    SessionClient().init(ProcessorClientMock(result));
    ProcessorUserRepository mockRepository = ProcessorUserRepository(ProcessorRepositoryConfigMock());

    dynamic expected = [
      {
        'UserID': 'irina',
        'UserName': 'Irina',
        'UserStatusID': '30',
        'UserStatusName': 'Working Task',
        'TaskCount': 2,
        'SectionCount': 4
      },
      {
        'UserID': 'asmith',
        'UserName': 'Angus Smith',
        'UserStatusID': '30',
        'UserStatusName': 'Available',
        'TaskCount': 0,
        'SectionCount': 1
      }
    ];

    expect(await mockRepository.teamAvailabilitySummary(), expected);
  });
}