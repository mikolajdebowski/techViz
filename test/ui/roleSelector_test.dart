import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/presenter/roleListPresenter.dart';
import 'package:techviz/session.dart';
import 'package:techviz/ui/roleSelector.dart';


class RoleListPresenterMockAllRoles extends Mock implements IRoleListPresenter{
  IRoleListView<Role> _view;

  @override
  void loadUserRoles(String userID) {
    List<Role> rolesList = [];
    rolesList.add(Role(id: 10, description: 'Attendant', isAttendant: true));
    rolesList.add(Role(id: 15, description: 'Technician', isTechnician: true));
    rolesList.add(Role(id: 20, description: 'Supervisor', isAttendant: true, isSupervisor: true));
    rolesList.add(Role(id: 25, description: 'Manager', isAttendant: true, isManager: true));
    rolesList.add(Role(id: 35, description: 'TechSupervisor', isTechnician: true, isTechSupervisor: true));
    rolesList.add(Role(id: 40, description: 'TechManager', isTechnician: true, isTechManager: true));

    _view.onRoleListLoaded(rolesList);
  }

  @override
  void view(IRoleListView view) {
    _view = view;
  }
}

class RoleListPresenterMockNoRoles extends Mock implements IRoleListPresenter{
  IRoleListView<Role> _view;

  @override
  void loadUserRoles(String userID) {
    _view.onRoleListLoaded([]);
  }

  @override
  void view(IRoleListView view) {
    _view = view;
  }
}



void main(){

  Widget makeTestableWidget({Widget child}){
    return MaterialApp(
      home: child,
    );
  }

  setUpAll((){
    //MOCKING - SESSION USER IRINA AS ATTENDANT AS DEFAULT ROLE
    Session().user = User(userID: 'irina', userRoleID: 10);
  });


  group('group test for specific role is hihglighted/selected for certain userRoleID', ()
  {
    int iteration = 0;
    List<int> idsArr = [10, 15, 20, 25, 35, 40];
    List<String> rolesArr = ['Attendant', 'Technician', 'Supervisor', 'Manager', 'TechSupervisor', 'TechManager'];

    setUp(()  {
      Session().user = User(userRoleID: idsArr[iteration]);
//      print('test setUp() ${Session().user.userRoleID},  ${rolesArr[iteration]}');
      iteration ++;
    });

    for(int i=0; i<rolesArr.length; i++){

      testWidgets('test for role ${rolesArr[i]} , with id ${idsArr[i]}', (WidgetTester tester) async {

        IRoleListPresenter presenter = RoleListPresenterMockAllRoles();
        RoleSelector selector = RoleSelector(roleListPresenter: presenter);
        await tester.pumpWidget(makeTestableWidget(child: selector));

        Iterable<VizOptionButton> listOfBtns = tester.widgetList<VizOptionButton>(find.byType(VizOptionButton));
        VizOptionButton roleBtn = listOfBtns.where((VizOptionButton btn) => btn.title == rolesArr[i]).first;
        expect(roleBtn.selected,  isTrue, reason: 'userRoleID is set to ${idsArr[i]}');
      });

    }
  });


  testWidgets('tests if all user roles were added', (WidgetTester tester) async {

    IRoleListPresenter presenter = RoleListPresenterMockAllRoles();
    RoleSelector selector = RoleSelector(roleListPresenter: presenter);
    await tester.pumpWidget(makeTestableWidget(child: selector));

    Iterable<VizOptionButton> listOfBtns = tester.widgetList<VizOptionButton>(find.byType(VizOptionButton));

    expect(listOfBtns, isNotEmpty, reason: 'list is empty');
    expect(listOfBtns, hasLength(6), reason: 'added 6 different user roles');
  });


  testWidgets('tests if theres no roles for the user', (WidgetTester tester) async {

    IRoleListPresenter presenter = RoleListPresenterMockNoRoles();
    RoleSelector selector = RoleSelector(roleListPresenter: presenter);
    await tester.pumpWidget(makeTestableWidget(child: selector));

    expect(find.text('No roles available for the user'), findsOneWidget);
  });


}

