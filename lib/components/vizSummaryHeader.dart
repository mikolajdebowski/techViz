import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class VizSummaryHeaderActions {
  void onItemTap(String headerKey);
}

class VizSummaryHeader extends StatelessWidget {
  final double height = 75;
  final String headerTitle;
  final String selectedEntryKey;
  final Map<String, int> entries;
  final VizSummaryHeaderActions actions;

  VizSummaryHeader({Key key, this.headerTitle, this.entries, this.selectedEntryKey, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> itensChildren = List<Widget>();

    Radius defaultRadius = Radius.circular(5.0);

    if(entries==null || entries.length==0){
        itensChildren.add(CircularProgressIndicator());
    }
    else{
      entries.forEach((final String entryKey, int count) {
        BorderSide bs = BorderSide(color: Colors.white, width: 1.0);
        Border borderHeader = Border(left: bs, top: bs);
        Border borderValue = Border(left: bs, bottom: bs);

        bool isNotHighlighted = selectedEntryKey == null || selectedEntryKey != entryKey;

        BoxDecoration decorationEntryHeader = BoxDecoration(border: borderHeader, color: (isNotHighlighted ? Color(0xFFAAAAAA) : Color(0xFFFFFFFF)));
        BoxDecoration decorationEntryValue = BoxDecoration(border: borderValue, color: Color(0xffffffff));

        Container containerHeader = Container(decoration: decorationEntryHeader, child: Center(child: Text(entryKey, key: Key('headerItemTitle'),)));
        Container containerValue = Container(decoration: decorationEntryValue, child: Center(child: Text(count.toString(), key: Key('headerItemValue'))));

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
                  actions.onItemTap(entryKey);
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
            child: Align(child: Text(headerTitle, key: Key('headerTitle'), style: TextStyle(color: Colors.white, fontWeight:
                FontWeight.bold)), alignment: Alignment.center),
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