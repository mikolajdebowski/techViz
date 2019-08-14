import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dataEntry/dataEntryGroup.dart';

abstract class VizSummaryHeaderActions {
  void onItemTap(String headerKey);
}

class VizSummaryHeader extends StatelessWidget {
  final double height = 48;
  final String headerTitle;
  final String selectedEntryKey;
  final List<DataEntryGroup> entries;
  final VizSummaryHeaderActions actions;
  final bool isProcessing;


  const VizSummaryHeader({Key key, this.headerTitle, this.entries, this.selectedEntryKey, this.actions, this.isProcessing = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> itemsChildren = <Widget>[];

    Radius defaultRadius = Radius.circular(3.0);
    bool isFirst = true;

    if(entries==null || entries.isEmpty){
      itemsChildren.add(CircularProgressIndicator());
    }
    else{
      entries.forEach((final DataEntryGroup dataEntryGroup) {

        BorderSide borderSide = BorderSide(color: Colors.white, width: 1.0);

        bool isNotHighlighted = selectedEntryKey == null || selectedEntryKey != dataEntryGroup.headerTitle;

        BoxDecoration decorationEntryHeader = BoxDecoration(border: isFirst ? Border(top: borderSide) : Border(left: borderSide, top: borderSide));


        Color highlightedFontColor = Color(0xFF535353);

        if(!isNotHighlighted){
          highlightedFontColor = Color(0xFF394f7d);
        }
        else{
          highlightedFontColor = Color(0xFF535353);
        }

        if(dataEntryGroup.highlightedDecoration!=null){
          highlightedFontColor = dataEntryGroup.highlightedDecoration();
        }

        String title = dataEntryGroup.headerTitle.toUpperCase() + ' (' + dataEntryGroup.entries.length.toString() + ')';
        TextStyle style = TextStyle(color: highlightedFontColor, fontWeight: FontWeight.w600);
        Key key = Key('headerItemTitle');

        AutoSizeText txtField = AutoSizeText(
          title,
          key: key,
          textAlign: TextAlign.center,
          style: style,
          maxLines: 1,
        );

        Container containerHeader = Container(decoration: decorationEntryHeader, child: Center(child: SizedBox(child: txtField,
        height: 17,)));

        Container underline = Container(
          height: 2,
          decoration: BoxDecoration(
            color: isNotHighlighted ? Color(0xFFdddddd) : Color(0xFF394f7d),
          )
        );

        Column column = Column(
          children: <Widget>[
           Padding(
              padding: const EdgeInsets.all(4.0),
              child: containerHeader,
            ),
            underline,
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

        itemsChildren.add(flexible);
      });
    }


    BorderRadiusGeometry borderGeoHeader = BorderRadius.only(topLeft: defaultRadius, topRight: defaultRadius);
    Border borderColor = Border.all(color: Colors.grey, width: 0.5);
    BoxDecoration decorationHeader = BoxDecoration(border: borderColor, color: Color(0xFFb7b7b7), borderRadius: borderGeoHeader);
    Row titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(headerTitle, key: Key('headerTitle'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ],
    );

    Container container = Container(
      decoration: decorationHeader,
      padding: EdgeInsets.only(top: 1.0, bottom: 1.0),
      child: Center(child: titleRow),
    );

    return Container(
      height: height,
      child: Column(
        children: <Widget>[
          container,
          Expanded(
            child: Row(
              key: Key('rowContainer'),
              children: itemsChildren,
            ),
          )
        ],
      ),
    );
  }
}