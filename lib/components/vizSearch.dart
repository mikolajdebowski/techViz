import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizElevated.dart';

class VizSearch extends StatefulWidget {
  VizSearch({Key key, this.title, this.onOKTapTapped, this.onBackTapped})
      : super(key: key);

  final String title;
  final VoidCallback onOKTapTapped;
  final VoidCallback onBackTapped;

  @override
  State<StatefulWidget> createState() {
    return VizSearchState();
  }
}

class VizSearchState extends State<VizSearch> {
  @override
  Widget build(BuildContext context) {
    var centralWidgets = <Widget>[
      Expanded(child: VizElevated(customWidget: Text('aa')))
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(centralWidgets: centralWidgets),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
