import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dataEntry/dataEntryGroup.dart';

abstract class VizSummaryHeaderActions {
  void onItemTap(String headerKey);
}

class VizSummaryHeader extends StatelessWidget {
  final double height = 75;
  final String headerTitle;
  final String selectedEntryKey;
  final List<DataEntryGroup> entries;
  final VizSummaryHeaderActions actions;
  final bool isProcessing;


  VizSummaryHeader({Key key, this.headerTitle, this.entries, this.selectedEntryKey, this.actions, this.isProcessing = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> itensChildren = <Widget>[];

    Radius defaultRadius = Radius.circular(3.0);
    bool isFirst = true;

    if(entries==null || entries.isEmpty){
        itensChildren.add(CircularProgressIndicator());
    }
    else{
      entries.forEach((final DataEntryGroup dataEntryGroup) {

        BorderSide borderSide = BorderSide(color: Colors.white, width: 1.0);

        bool isNotHighlighted = selectedEntryKey == null || selectedEntryKey != dataEntryGroup.headerTitle;

        BoxDecoration decorationEntryHeader = BoxDecoration(border: isFirst ? Border(top: borderSide) : Border(left: borderSide, top: borderSide), color: isNotHighlighted ? Color(0xFFAAAAAA) : Color(0xFFFFFFFF));
        BoxDecoration decorationEntryValue = BoxDecoration(border: isFirst ? Border(top: borderSide, bottom: borderSide) : Border(left: borderSide, top: borderSide, bottom: borderSide), color: Color(0xFFFFFFFF));

        Container containerHeader = Container(decoration: decorationEntryHeader, child: Center(child: Text(dataEntryGroup.headerTitle, key: Key('headerItemTitle'),)));

        Color highlightedFontColor = Colors.black;
        if(dataEntryGroup.highlightedDecoration!=null){
          highlightedFontColor = dataEntryGroup.highlightedDecoration();
        }

        Container containerValue = Container(decoration: decorationEntryValue, child: Center(child: Text(dataEntryGroup.entries.length.toString(), style: TextStyle(color: highlightedFontColor), key: Key('headerItemValue'))));

        Column column = Column(
          children: <Widget>[
            Flexible(child: containerHeader),
            Flexible(child: containerValue),
          ],
        );

        Flexible flexible = Flexible(
          child: Container(
            child: GestureDetector(
              child: column,
              onTap: () {
                if (actions != null) {
                  actions.onItemTap(dataEntryGroup.headerTitle);
                }
              },
            ),
          ),
        );

        itensChildren.add(flexible);
      });
    }


    BorderRadiusGeometry borderGeoHeader = BorderRadius.only(topLeft: defaultRadius, topRight: defaultRadius);
    Border borderColor = Border.all(color: Colors.grey, width: 0.5);
    BoxDecoration decorationHeader = BoxDecoration(border: borderColor, color: Color(0xFF505b6a), borderRadius: borderGeoHeader);

    return Container(
      height: height,
      child: Column(
        children: <Widget>[
          Container(
            decoration: decorationHeader,
            padding: EdgeInsets.only(top: 1.0, bottom: 1.0),
            child: Center(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(headerTitle, key: Key('headerTitle'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Opacity(opacity: isProcessing ? 1.0 : 0.0, child: Padding(child: SizedBox(child: CircularProgressIndicator(strokeWidth: 2), width: 10, height: 10), padding: EdgeInsets.only(left: 5)))
              ],
            )),
          ),
          Expanded(
            child: Row(
              key: Key('rowContainer'),
              children: itensChildren,
            ),
          )
        ],
      ),
    );
  }
}