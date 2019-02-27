import 'package:flutter/material.dart';

class VizLegend extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var legend = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: Color.fromRGBO(150, 207, 150, 1)),
            ),
            Padding(
              padding: EdgeInsets.only(right:15.0),
              child: Padding(
                padding: EdgeInsets.only(left:18.0),
                child: Text("Personal"),
              ),

            ),

          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: Color.fromRGBO(23, 95, 199, 1)),
            ),
            Padding(
              padding: EdgeInsets.only(right:15.0),
              child: Padding(
                padding: EdgeInsets.only(left:11.0),
                child: Text("Team Avg"),
              ),

            ),
          ],
        )
      ],
    );

    return legend;

  }
}

