import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizElevatedButton.dart';

class VizSelector extends StatefulWidget {
  VizSelector(
      {Key key,
      this.title,
      this.onOKTapTapped,
      this.onBackTapped,
      this.multiple = false,
      this.options})
      : super(key: key);

  final String title;
  final bool multiple;
  final void Function(List<VizSelectorOption>) onOKTapTapped;
  final VoidCallback onBackTapped;
  final List<VizSelectorOption> options;

  @override
  State<StatefulWidget> createState() {
    return new VizSelectorState();
  }
}

class VizSelectorState extends State<VizSelector> {
  void callOnOKTapTapped() {
    widget.onOKTapTapped(widget.options);
    goBack();
  }

  void goBack() {
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      appBar: new ActionBar(widget.title, titleColor: Colors.blue),
      body: new Container(
        child: new GridView.count(
            crossAxisCount: 3,
            children: <String>[
              'A','B','C','D',
            ].map((String option) {
              return new VizElevatedButton(title: option);
            }).toList()),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class VizSelectorOption {
  VizSelectorOption(this.id, this.description);

  Object id;
  String description;
}
