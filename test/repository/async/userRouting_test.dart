
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/UserRouting.dart';
import '../../_mocks/messageClientMock.dart';

void main() {
  StreamController<dynamic> streamController;
  IUserRouting iUserRounting;

  setUp((){
    streamController = StreamController<dynamic>();
    iUserRounting = UserRouting(MessageClientMock<dynamic>(streamController));
  });

  test('tests parser',() {
    dynamic json = {'userID':'10', 'userRoleID': '123', 'userStatusID': '10'};
    expect(iUserRounting.parser(json), isInstanceOf<User>());
  });

  test('listenQueue should throws an UnimplementedError exception',() {
    expect(() => iUserRounting.listenQueue(null), throwsUnimplementedError);
  });

  test('publishMessage should return true',(){
      Future<dynamic> future = iUserRounting.publishMessage('whatever');
      streamController.add(true);
      expect(future, completion(true));
  });

  tearDown((){
    streamController?.close();
  });
}

