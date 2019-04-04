import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VizSummaryHeader extends StatefulWidget {
  final String headerTitle;
  final Color primaryColor;
  final Color secondaryColor;
  final List<VizSummaryHeaderEntry> entries;

  VizSummaryHeader(this.headerTitle, this.entries, {this.primaryColor, this.secondaryColor}) {
    assert(this.headerTitle != null);
    assert(this.entries != null);
    assert(this.entries.length > 0);
  }

  @override
  State<StatefulWidget> createState() => VizSummaryHeaderState();
}

class VizSummaryHeaderState extends State<VizSummaryHeader> {
  @override
  Widget build(BuildContext context) {
    List<Widget> itensChildren = List<Widget>();

    Radius defaultRadius = Radius.circular(6.0);


    int lastIdx = widget.entries.length-1;
    widget.entries.asMap().forEach((int idx, VizSummaryHeaderEntry entry) {
      BorderSide bs = BorderSide(color: Colors.white, width: 1.0);

      Border border = Border(left: idx>0 && idx<=lastIdx? bs: BorderSide.none, top: bs);
      BoxDecoration decorationEntryHeader = BoxDecoration(border: border, color: Color(0xFFAAAAAA));
      BoxDecoration decorationEntryValue = BoxDecoration(border: border);

      Flexible item = Flexible(
        child: Column(children: <Widget>[
          Flexible(
            child: Container(decoration: decorationEntryHeader, child: Center(child: Text(entry.entryName))),
          ),
          Flexible(child: Container(decoration: decorationEntryValue, child: Center(child: Text(entry.value.toString())))),
        ],),
      );
      itensChildren.add(item);
    });

    BorderRadiusGeometry borderGeoHeader = BorderRadius.only(topLeft: defaultRadius, topRight: defaultRadius);
    Border borderColor = Border.all(color: Colors.grey, width: 0.5);
    BoxDecoration decorationHeader = BoxDecoration(border: borderColor, color: Color(0xFF505b6a), borderRadius: borderGeoHeader);

    return Column(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Container(
            decoration: decorationHeader,
            padding: EdgeInsets.all(5.0),
            child: Align(child: Text(widget.headerTitle, style: TextStyle(color: Colors.white)), alignment: Alignment.centerLeft),
          ),
        ),
        Flexible(
          flex: 2,
            child: Row(
          children: itensChildren,
        )),
      ],
    );
  }
}

class VizSummaryHeaderEntry {
  final String entryName;
  final dynamic value;

  VizSummaryHeaderEntry(this.entryName, this.value);
}
