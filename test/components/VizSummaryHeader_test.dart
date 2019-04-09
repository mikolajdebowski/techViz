import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/components/vizSummaryHeader.dart';

void main(){

  group('VizSummaryHeader', (){

    test('VizSummaryHeaderEntry', (){
      VizSummaryHeaderEntry entryNumber = VizSummaryHeaderEntry('Entry 1', 1);
      expect(entryNumber.entryName, equals('Entry 1'));
      expect(entryNumber.value, equals(1));
    });

    testWidgets('VizSummaryHeader', (WidgetTester tester) async {

      VizSummaryHeaderEntry entry1 = VizSummaryHeaderEntry('Entry 1', 1);
      VizSummaryHeaderEntry entry2 = VizSummaryHeaderEntry('Entry 2', 2);

      VizSummaryHeader header = VizSummaryHeader(headerTitle: 'Header title', entries: [entry1,entry2]);

      await tester.pumpWidget( MaterialApp(home: header));

      expect(find.text('Entry 1'), findsOneWidget);
      expect(find.text('Entry 2'), findsOneWidget);
    });
  });
}