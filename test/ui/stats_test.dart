
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/ui/stats.dart';

void main() {
  testWidgets('Stats widget', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Stats()));
  });
}
