
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/ui/config.dart';

void main() {
  testWidgets('Config widget', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Config()));
  });
}

