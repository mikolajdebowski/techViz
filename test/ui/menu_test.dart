
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/ui/menu.dart';

void main() {
  testWidgets('Menu widget', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Menu()));
  });
}

