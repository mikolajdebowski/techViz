
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/UserRouting.dart';
import 'iMessageClientMock.dart';

void main() {

  IUserRouting iUserRounting;

  setUpAll((){
    iUserRounting = UserRouting(MessageClientMock());
  });

  test('tests parser',() {
    dynamic json = {'userID':'10', 'userRoleID': '123', 'userStatusID': '10'};
    expect(iUserRounting.parser(json), isInstanceOf<User>());
  });

  test('listenQueue should throws an UnimplementedError exception',() {
    expect(() => iUserRounting.listenQueue(null), throwsUnimplementedError);
  });

  test('publishMessage should return true',() async{
      expect(await iUserRounting.publishMessage('whatever'), true);
  });
}

