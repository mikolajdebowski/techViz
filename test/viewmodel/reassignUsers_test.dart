import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/viewmodel/reassignUsers.dart';

void main(){
  test('Instance by constructor ', (){
    ReassignUser reassignUser = ReassignUser('tester1', 'tester', 10, 3);
    expect(reassignUser.userID, 'tester1');
    expect(reassignUser.userName, 'tester');
    expect(reassignUser.sectionsCount, 10);
    expect(reassignUser.taskCount, 3);
  });

  test('Instance by Map Function', (){
    Map<String,dynamic> map = <String,dynamic>{};
    map['UserID'] = 'tester1';
    map['UserName'] = 'tester';
    map['SectionCount'] = 10;
    map['TaskCount'] = 3;

    ReassignUser reassignUser = ReassignUser.fromMap(map);
    expect(reassignUser.userID, 'tester1');
    expect(reassignUser.userName, 'tester');
    expect(reassignUser.sectionsCount, 10);
    expect(reassignUser.taskCount, 3);
  });
}