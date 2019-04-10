import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class VizSummaryHeaderActions {
  void onItemTap(String headerKey);
}

class VizSummaryHeader extends StatelessWidget {
  final double height = 90;
  final String headerTitle;
  final String selectedEntryKey;
  final Map<String, int> entries;
  final VizSummaryHeaderActions actions;

  VizSummaryHeader({Key key, this.headerTitle, this.entries, this.selectedEntryKey, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> itensChildren = List<Widget>();

    Radius defaultRadius = Radius.circular(6.0);

    //int lastIdx = entries.length - 1;
    entries.forEach((final String entryKey, int count) {
      BorderSide bs = BorderSide(color: Colors.white, width: 1.0);

      //Border borderHeader = Border(left: idx > 0 && idx <= lastIdx ? bs : BorderSide.none, top: bs);
      //Border borderValue = Border(left: idx > 0 && idx <= lastIdx ? bs : BorderSide.none, top: bs, bottom: bs);

      Border borderHeader = Border(left: bs, top: bs);
      Border borderValue = Border(left: bs, top: bs, bottom: bs);

      bool isNotHighlighted = selectedEntryKey == null || selectedEntryKey != entryKey;

      BoxDecoration decorationEntryHeader =
          BoxDecoration(border: borderHeader, color: (isNotHighlighted ? Color(0xFFAAAAAA) : Color(0xFF999999)));
      BoxDecoration decorationEntryValue = BoxDecoration(border: borderValue, color: (isNotHighlighted ? Colors.transparent : Color(0x22000000)));

      Container containerHeader = Container(decoration: decorationEntryHeader, child: Center(child: Text(entryKey)));
      Container containerValue = Container(decoration: decorationEntryValue, child: Center(child: Text(count.toString())));

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

    BorderRadiusGeometry borderGeoHeader = BorderRadius.only(topLeft: defaultRadius, topRight: defaultRadius);
    Border borderColor = Border.all(color: Colors.grey, width: 0.5);
    BoxDecoration decorationHeader = BoxDecoration(border: borderColor, color: Color(0xFF505b6a), borderRadius: borderGeoHeader);

    return Container(
      height: height,
      child: Column(
        children: <Widget>[
          Container(
            decoration: decorationHeader,
            padding: EdgeInsets.all(5.0),
            child: Align(child: Text(headerTitle, style: TextStyle(color: Colors.white)), alignment: Alignment.centerLeft),
          ),
          Expanded(
            child: Row(
              children: itensChildren,
            ),
          )
        ],
      ),
    );
  }
}