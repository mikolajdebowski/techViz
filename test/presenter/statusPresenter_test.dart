
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/statusPresenter.dart';
import 'package:techviz/repository/userStatusRepository.dart';
import 'package:techviz/service/userService.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class UserServiceMock implements IUserService{
  @override
  Future<void> update(String userID, {int statusID, String roleID}) {
    assert(userID!=null);
    assert(statusID!=null || roleID!=null);
    return Future<void>.value();
  }

  @override
  void cancelListening() {

  }

  @override
  void dispose() {

  }

  @override
  void listenAsync() {

  }
}

class UserStatusRepositoryMock implements IUserStatusRepository{
  @override
  Future fetch() {
    return Future<int>.value(1);
  }

  @override
  Future<List<UserStatus>> getStatuses() {
    return Future<List<UserStatus>>.value([UserStatus(1, 'Online', true), UserStatus(2, 'OFF-SHIFT', false)]);
  }
}

class StatusViewMock extends Mock implements IStatusView{}

void main(){
  StatusViewMock statusViewMock;
  StatusPresenter presenter;
  setUpAll((){
    statusViewMock = StatusViewMock();
    kiwi.Container().registerInstance<IUserStatusRepository,UserStatusRepositoryMock>(UserStatusRepositoryMock());
  });

  setUp((){
    presenter = StatusPresenter(statusViewMock, userService: UserServiceMock());
  });

  test('loadUserStatus should call back onStatusListLoaded', () async{
    presenter.loadUserStatus();

    await untilCalled(statusViewMock.onStatusListLoaded(any));

    VerificationResult result = verify(statusViewMock.onStatusListLoaded(captureAny));
    expect(result.callCount, 1, reason: 'onStatusListLoaded not called once');
  });

  test('update Future should completer when statusID is given', () async{
    Future updateFuture = presenter.update('irrelevant', statusID: 1);
    expect(updateFuture, completion(anything));
  });
}