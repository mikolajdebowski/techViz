import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VizSummaryHeader extends StatelessWidget {
  final double height = 90;
  final String headerTitle;
  final bool selected;
  final List<VizSummaryHeaderEntry> entries;

  VizSummaryHeader({Key key, this.headerTitle, this.entries, this.selected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> itensChildren = List<Widget>();

    Radius defaultRadius = Radius.circular(6.0);

    int lastIdx = entries.length - 1;
    entries.asMap().forEach((int idx, VizSummaryHeaderEntry entry) {
      BorderSide bs = BorderSide(color: Colors.white, width: 1.0);

      Border borderHeader = Border(left: idx > 0 && idx <= lastIdx ? bs : BorderSide.none, top: bs);
      Border borderValue = Border(left: idx > 0 && idx <= lastIdx ? bs : BorderSide.none, top: bs, bottom: bs);

      BoxDecoration decorationEntryHeader = BoxDecoration(border: borderHeader, color: selected ? Color(0xFF888888) : Color(0xFFAAAAAA));
      BoxDecoration decorationEntryValue = BoxDecoration(border: borderValue);

      Container containerHeader = Container(decoration: decorationEntryHeader, child: Center(child: Text(entry.entryName)));
      Container containerValue = Container(decoration: decorationEntryValue, child: Center(child: Text(entry.value.toString())));

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
            onTap: (){
              if(entry.onEntryTapCallback!=null){
                entry.onEntryTapCallback();
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

class VizSummaryHeaderEntry {
  final String entryName;
  final dynamic value;
  final Function onEntryTapCallback;

  VizSummaryHeaderEntry(this.entryName, this.value, {this.onEntryTapCallback});
}
