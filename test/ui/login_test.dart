import 'package:flutter/material.dart';
import 'package:techviz/ui/login.dart';
import 'package:flutter_test/flutter_test.dart';

//class Mock

void main(){

//  test('title', (){
//
//    // setup
//
//    // run
//
//    // verify
//
//  });

  Widget makeTestableWidget({Widget child}){
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('widget test example', (WidgetTester tester) async{

    Login loginPage = Login();
    await tester.pumpWidget(makeTestableWidget(child: loginPage));



//    Finder loginBtnFinder = find.byKey(Key('loginBtn'));
//    await tester.tap(loginBtnFinder);
//
//
//    print('test finished');

  });





  test('empty username returns error string', (){
    print('test 1');

    var result = UsernameFieldValidator.validate('');
    expect(result, 'Username is required');
  });

  test('non-empty username returns null', (){
    print('test 2');

    var result = UsernameFieldValidator.validate('username');
    expect(result, null);
  });




  test('empty password returns error string', (){

    var result = PasswordFieldValidator.validate('');
    expect(result, 'Password is required');
  });

  test('non-empty password returns null', (){

    var result = PasswordFieldValidator.validate('password');
    expect(result, null);
  });



}