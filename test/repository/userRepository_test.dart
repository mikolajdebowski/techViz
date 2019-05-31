import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/UserRouting.dart';
import 'package:techviz/repository/local/userTable.dart';
import 'package:techviz/repository/userRepository.dart';

class UserRemoteRepositoryMock implements IUserRemoteRepository{
  @override
  Future<Map> fetch() {
    Map<String,dynamic> toReturn = <String,dynamic>{};
    toReturn['UserID'] = '1';
    toReturn['UserID'] = 'User 1';
    toReturn['UserStatusID'] = 1;
    toReturn['UserRoleID'] = 1;

    return Future<Map>.value(toReturn);
  }

  @override
  Future<List<Map>> usersBySectionsByTaskCount() {
    List<Map> map = <Map>[];
    return Future<List<Map>>.value(map);
  }
}

class UserRoutingMock implements IUserRouting{
  @override
  void listenQueue(Function callback, {Function callbackError}) {
    throw UnimplementedError();
  }

  @override
  Future publishMessage(dynamic message) {
    return Future<int>.value(1);
  }

  @override
  User parser(dynamic dynamic) {
    return null;
  }
}

class UserTableMock implements IUserTable{
  @override
  Future<User> getUser(String userID) {
    if(userID == '1'){
      return Future<User>.value(User());
    }
    else
      return null;
  }

  @override
  Future<int> update(String userID, {String statusID, String roleID}) {
    return Future<int>.value(1);
  }
}


void main(){
  UserRepository mockRepository;

  setUpAll(() async{
    mockRepository = UserRepository(UserRemoteRepositoryMock(), UserRoutingMock(), UserTableMock());
  });

  test('fetch should return an user map', () async {
    expect(await mockRepository.fetch(), isInstanceOf<Map>(), reason: 'not a Map');

  });

  test('getUser should ', () async {
    expect(await mockRepository.getUser("1"), isInstanceOf<User>());
  });

  test('unable to find local user by ID', () async {
    expect(await mockRepository.getUser("2"), null);
  });

  test('should update roleID', () async {
    expect(await mockRepository.update("1", roleID: "1"), 1);
  });

  test('should update statusID', () async {
    expect(await mockRepository.update("1", statusID: "1"), 1);
  });

  test('usersBySectionsByTaskCount', () async {
    expect(await mockRepository.usersBySectionsByTaskCount(), isInstanceOf<List<Map>>());
  });
}