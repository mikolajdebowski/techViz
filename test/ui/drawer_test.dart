
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/session.dart';
import 'package:techviz/ui/drawer.dart';
import 'package:techviz/ui/login.dart';
import 'package:techviz/ui/managerView.dart';
import 'package:techviz/ui/taskView.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {

	setUp((){
		Session().user = User(
			userID: 'tester',
			userName: 'Tester'
		);

		Session().role = Role(
			id: 1
		);
	});

	testWidgets('Drawer userNameText title should be "Tester"', (WidgetTester tester) async {
		GlobalKey<TaskViewState> gkey = GlobalKey<TaskViewState>();
		await tester.pumpWidget(MaterialApp(home: MenuDrawer(gkey)));

		Text userNameText = tester.widget<Text>(find.byKey(Key('userNameText')));
		expect(userNameText.data, 'Tester');
	});

	testWidgets('Drawer userIDText title should be "tester"', (WidgetTester tester) async {
		GlobalKey<TaskViewState> gkey = GlobalKey<TaskViewState>();
		await tester.pumpWidget(MaterialApp(home: MenuDrawer(gkey)));

		Text userIDText = tester.widget<Text>(find.byKey(Key('userIDText')));
		expect(userIDText.data, 'tester');
	});

	testWidgets('Menu item My Tasks should be marked as selected if user role is Attendant/Technician', (WidgetTester tester) async {
		Session().role = Role(
				id: 1,
				isAttendant: true,
				isTechManager: true
		);

		GlobalKey<TaskViewState> gkey = GlobalKey<TaskViewState>();
		await tester.pumpWidget(MaterialApp(home: MenuDrawer(gkey)));

		MenuDrawerItem myTasksItem = tester.widget<MenuDrawerItem>(find.byKey(Key('myTasksItemKey')));
		expect(myTasksItem.selected, true);
		expect(myTasksItem.selectedBackgroundColor, Color(0xFFEAEDF2));
		expect(myTasksItem.selectedFontColor, Color(0xFF415990));
	});

	testWidgets('Menu item Manager Summary should be marked as selected if user role is Manager/Supervisor', (WidgetTester tester) async {
		Session().role = Role(
				id: 1,
				isManager: true,
				isSupervisor: true,
				isTechManager: true,
				isTechSupervisor: true
		);

		GlobalKey<ManagerViewState> gkey = GlobalKey<ManagerViewState>();
		await tester.pumpWidget(MaterialApp(home: MenuDrawer(gkey)));

		MenuDrawerItem managerSummaryItem = tester.widget<MenuDrawerItem>(find.byKey(Key('managerSummaryItemKey')));
		expect(managerSummaryItem.selected, true);
		expect(managerSummaryItem.selectedBackgroundColor, Color(0xFFEAEDF2));
		expect(managerSummaryItem.selectedFontColor, Color(0xFF415990));
	});


	testWidgets('Menu items settings/help/about should be disabled', (WidgetTester tester) async {
		GlobalKey<TaskViewState> gkey = GlobalKey<TaskViewState>();
		await tester.pumpWidget(MaterialApp(home: MenuDrawer(gkey)));

		MenuDrawerItem settingsItem = tester.widget<MenuDrawerItem>(find.byKey(Key('settingsItemKey')));
		MenuDrawerItem helpItem = tester.widget<MenuDrawerItem>(find.byKey(Key('helpItemKey')));
		MenuDrawerItem aboutItem = tester.widget<MenuDrawerItem>(find.byKey(Key('aboutItemKey')));

		expect(settingsItem.disabled, true);
		expect(helpItem.disabled, true);
		expect(aboutItem.disabled, true);

	});

	testWidgets('Menu logout button should clear the session and redirect to the login view', (WidgetTester tester) async {

		//tests envolving Session class can only be done after Session dependecies can be resolved (injected)

//		GlobalKey<TaskViewState> gkey = GlobalKey<TaskViewState>();
//		final mockObserver = MockNavigatorObserver();
//		await tester.pumpWidget(MaterialApp(home: MenuDrawer(gkey), navigatorObservers: [mockObserver]));
//
//		await tester.tap(find.byKey(Key('logoutKey')));
//
//		await tester.pumpAndSettle(Duration(seconds: 5));  //STUCKS BECAUSE SESSION DEPENDS ON REMOTE CALL.
//
//		verify(mockObserver.didPush(any, any));
//
//		expect(find.byType(Login), findsOneWidget);


	});

}

