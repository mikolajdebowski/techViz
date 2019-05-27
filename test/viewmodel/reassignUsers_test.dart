import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/viewmodel/reassignUsers.dart';

void main(){
  test('fromMap Function', (){
    Map<String,dynamic> map = Map<String,dynamic>();
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