import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizElevated.dart';

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
    return VizSelectorState(options);
  }
}

class VizSelectorState extends State<VizSelector> {
  List<VizSelectorOption> options;

  VizSelectorState(List<VizSelectorOption> options) {
    if (this.options == null) {
      this.options = options;
    }
  }

  void onOkTap(){
    widget.onOKTapTapped(options);
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    var defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));

    var actions = <Widget>[];
    if (widget.multiple) {
      actions.add(VizButton('All', onTap: onSelectAllTapped));
      actions.add(VizButton('None', onTap: onSelectNoneTapped));
    }

    var body = GridView.count(
        shrinkWrap: true,
        padding: EdgeInsets.all(4.0),
        childAspectRatio: options.length > 4 ? 1.0 : 2.0,
        addAutomaticKeepAlives: false,
        crossAxisCount: options.length > 6 ? 6 : options.length,
        children: options.map((VizSelectorOption option) {
          return VizOptionButton(
              option.description,
              key: GlobalKey(),
              selected: option.selected);
        }).toList());

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: ActionBar(title: widget.title, titleColor: Colors.blue, tailWidget: VizButton('OK', onTap: onOkTap, highlighted: true)),
        body: Container(
          decoration: defaultBgDeco,
          constraints: BoxConstraints.expand(),
          child: body,
        ),
    );


  }


  void onSelectAllTapped() {
    if (options != null) {
      setState(() {
        options.forEach((option) {
          option.selected = true;
        });
      });
    }
  }

  void onSelectNoneTapped() {
    if (options != null) {
      setState(() {
        options.forEach((option) {
          option.selected = false;
        });
      });
    }
  }
}

class VizSelectorOption {
  VizSelectorOption(this.id, this.description, {this.selected = false});

  Object id;
  String description;
  bool selected;
}
