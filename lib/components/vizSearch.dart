import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';

class VizSearch extends StatefulWidget {
  VizSearch({Key key, this.title, this.onOKTapTapped, this.onBackTapped}): super(key: key);

  final String title;
  final VoidCallback onOKTapTapped;
  final VoidCallback onBackTapped;

  @override
  State<StatefulWidget> createState() {
    return new VizSearchState();
  }
}

class VizSearchState extends State<VizSearch> {

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      backgroundColor: Colors.black,
      appBar: new ActionBar(widget.title, titleColor: Colors.blue),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(widget.title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
