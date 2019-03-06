

import 'package:flutter/widgets.dart';

class VizLegend extends StatelessWidget {
  final List<VizLegendModel> items;

  VizLegend(this.items);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (items != null && items.length > 0) {
      items.forEach((VizLegendModel legend) {
        children.add(Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: Text(legend.title),
            ),
            Container(
              padding: EdgeInsets.only(left: 5.0),
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: legend.color),
            ),
          ],
        ));
      });
    }

    Column column = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
    return column;
  }
}

class VizLegendModel {
  final Color color;
  final String title;

  VizLegendModel(this.color, this.title);
}
