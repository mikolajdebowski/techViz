import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizElevatedButton.dart';
import 'package:techviz/components/vizExpandedButton.dart';

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
    return new VizSelectorState(options);
  }
}

class VizSelectorState extends State<VizSelector> {
  VizSelectorState(List<VizSelectorOption> options) {
    if (this.options == null) {
      this.options = options;
    }
  }

  List<VizSelectorOption> options;

  @override
  Widget build(BuildContext context) {
    var colorBtnOK = [
      const Color(0xFF86bf39),
      const Color(0xFF0f7c6a),
    ];

    var actions = <Widget>[];

    if (widget.multiple) {
      actions
          .add(new VizExpandedButton(title: 'All', onTap: onSelectAllTapped));
      actions
          .add(new VizExpandedButton(title: 'None', onTap: onSelectNoneTapped));
    }
    actions.add(new VizExpandedButton(
        title: 'OK', onTap: callOnOKTapTapped, customBackground: colorBtnOK));

    return new Scaffold(
        backgroundColor: Colors.black,
        appBar: new ActionBar(widget.title, titleColor: Colors.blue),
        body: new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: new GridView.count(
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(4.0),
                    childAspectRatio: 2.0,
                    addAutomaticKeepAlives: false,
                    crossAxisCount: options.length > 5 ? 5 : options.length,
                    children: options.map((VizSelectorOption option) {
                      return new VizElevatedButton(
                          key: new GlobalKey(),
                          title: option.description,
                          selectable: true,
                          selected: option.selected);
                    }).toList())),
            new Positioned(
                height: 60.0,
                width: MediaQuery.of(context).size.width,
                bottom: 0.0,
                child: new Row(children: actions))
          ],
        ));
  }

  void callOnOKTapTapped() {
    widget.onOKTapTapped(options);
    goBack();
  }

  void goBack() {
    Navigator.maybePop(context);
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
