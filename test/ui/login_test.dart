
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/ui/login.dart';

void main() {
  testWidgets('Login widget', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Login()));
  });
}

