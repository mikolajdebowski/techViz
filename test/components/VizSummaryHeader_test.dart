import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:techviz/components/dataEntry/dataEntry.dart';
import 'package:techviz/components/dataEntry/dataEntryGroup.dart';
import 'package:techviz/components/vizSummaryHeader.dart';

class ClassForVizSummaryHeaderActions extends Mock implements VizSummaryHeaderActions{
  @override
  void onItemTap(String headerKey) {
    print(headerKey);
  }
}

void main(){
  group('VizSummaryHeader', (){

    testWidgets('header title should contains \'header title\' text', (WidgetTester tester) async {

      VizSummaryHeader header = VizSummaryHeader(headerTitle:'header title');

      await tester.pumpWidget(MaterialApp(home: header));

      Finder headerTitleWidget = find.byKey(Key('headerTitle'));

      Text text = tester.widget<Text>(headerTitleWidget);
      expect(text.data, 'header title', reason: 'expects data should be \'header title\'');
    });

    testWidgets('should shows circular progress indicator when data is not available (yet)', (WidgetTester tester) async {

      VizSummaryHeader header = VizSummaryHeader(headerTitle:'header title', entries: null);
      await tester.pumpWidget(MaterialApp(home: header));

      Finder rowContainerFinder = find.byKey(Key('rowContainer'));
      expect(rowContainerFinder, findsOneWidget, reason: 'expects findsOneWidget');

      Row rowContainer = tester.widget<Row>(rowContainerFinder);
      expect(rowContainer.children.first.runtimeType, CircularProgressIndicator, reason: 'expects CircularProgressIndicator');
    });

    testWidgets('should have 3 columns named Column1,Column2 and Column3 with values 1, 2 and 3 respectively', (WidgetTester tester) async {

      List<DataEntryGroup> listEntries = <DataEntryGroup>[];
      listEntries.add(DataEntryGroup('Column 1', <DataEntry>[]));
      listEntries.add(DataEntryGroup('Column 2', <DataEntry>[]));
      listEntries.add(DataEntryGroup('Column 3', <DataEntry>[]));

      VizSummaryHeader header = VizSummaryHeader(headerTitle:'header title', entries: listEntries);
      await tester.pumpWidget(MaterialApp(home: header));

      Finder rowContainerFinder = find.byKey(Key('rowContainer'));
      expect(rowContainerFinder, findsOneWidget, reason: 'expects findsOneWidget');

      Finder headerItemTitleFinder = find.descendant(of: rowContainerFinder, matching: find.byKey(Key('headerItemTitle')));
      expect(headerItemTitleFinder, findsNWidgets(3), reason: 'expects 3 title widgets');

      Finder headerItemValueFinder = find.descendant(of: rowContainerFinder, matching: find.byKey(Key('headerItemValue')));
      expect(headerItemValueFinder, findsNWidgets(3), reason: 'expects 3 value widgets');
    });

    testWidgets('should have one column with the text font highlighted in red', (WidgetTester tester) async {

      List<DataEntryGroup> listEntries = <DataEntryGroup>[];
      listEntries.add(DataEntryGroup('highlighted in red', <DataEntry>[], highlightedDecoration: (){ return Colors.red;}));

      VizSummaryHeader header = VizSummaryHeader(headerTitle:'header title', entries: listEntries);
      await tester.pumpWidget(MaterialApp(home: header));

      Finder headerItemValueFinder = find.byKey(Key('headerItemValue'));

      Text textWidget = tester.widget(headerItemValueFinder);
      expect(textWidget.style.color, Colors.red, reason: 'color property should be Red');
    });

//    testWidgets('should tap', (WidgetTester tester) async {
//
//      List<DataEntryGroup> listEntries = <DataEntryGroup>[];
//      listEntries.add(DataEntryGroup('tappable header item', <DataEntry>[]));
//
//      ClassForVizSummaryHeaderActions actionImplementation = ClassForVizSummaryHeaderActions();
//
//      VizSummaryHeader header = VizSummaryHeader(headerTitle:'header title', entries: listEntries, actions: actionImplementation);
//      await tester.pumpWidget(MaterialApp(home: header));
//
//      Finder headerItemValueFinder = find.byKey(Key('headerItemValue'));
//
//      await tester.tap(headerItemValueFinder);
//
//      await untilCalled(actionImplementation.onItemTap(any));
//
//      //List<dynamic> a = verify(actionImplementation.onItemTap(any)).captured;
//    });
  });
}