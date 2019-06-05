
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/local/userTable.dart';

import '../mock/localRepositoryMock.dart';

void main() {

  test('insertUser should insert a user and return 1 (number of row inserteds)', () async {
    LocalRepositoryMock localRepo = LocalRepositoryMock();
    IUserTable userTable = UserTable(localRepo);
    Map<String,dynamic> map = <String,dynamic>{};
    expect(await userTable.insertUser(map), 1);
  });

  test('should update UserRole of the user and return 1 (rnumber of row inserteds)', () async {
    LocalRepositoryMock localRepo = LocalRepositoryMock();
    IUserTable userTable = UserTable(localRepo);
    expect(await userTable.updateUser('1', roleID: '1'), 1);
  });

  test('updateUser should update UserStatus and return 1 (number of row inserteds)', () async {
    LocalRepositoryMock localRepo = LocalRepositoryMock();
    IUserTable userTable = UserTable(localRepo);
    expect(await userTable.updateUser('1', statusID: '1'), 1);
  });

  test('getUser should return a user', () async {
    Map<String,dynamic> userMap = <String,dynamic>{};
    userMap['UserID'] = '1';
    userMap['UserName'] = '1';
    userMap['UserRoleID'] = '1';
    userMap['UserStatusID'] = '1';
    userMap['StaffID'] = '1';

    LocalRepositoryMock localRepo = LocalRepositoryMock(values: [userMap]);
    IUserTable userTable = UserTable(localRepo);
    expect(await userTable.getUser('1'), isInstanceOf<User>());
  });

  test('getUser should throws \'User was not found\' exception', () async {
    LocalRepositoryMock localRepo = LocalRepositoryMock();
    IUserTable userTable = UserTable(localRepo);
    expect(() => userTable.getUser('1'), throwsException);
  });
}