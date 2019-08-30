import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/model/user.dart';
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

  @override
  Future<List<Map>> teamAvailabilitySummary() {
    List<Map> map = <Map>[];
    return Future<List<Map>>.value(map);
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
  Future<int> insertUser(Map map) {
    return Future<int>.value(1);
  }

  @override
  Future<int> updateUser(String userID, {String statusID, String roleID}) {
    return Future<int>.value(1);
  }
}


void main(){
  UserRepository mockRepository;

  setUpAll(() async{
    mockRepository = UserRepository(UserRemoteRepositoryMock(), UserTableMock());
  });

  test('fetch should 1, which means one user has been inserted in the local database', () async {
    expect(await mockRepository.fetch(), 1);
  });

  test('getUser should ', () async {
    expect(await mockRepository.getUser("1"), isInstanceOf<User>());
  });

  test('unable to find local user by ID', () async {
    expect(await mockRepository.getUser("2"), null);
  });

  test('usersBySectionsByTaskCount', () async {
    expect(await mockRepository.usersBySectionsByTaskCount(), isInstanceOf<List<Map>>());
  });
}