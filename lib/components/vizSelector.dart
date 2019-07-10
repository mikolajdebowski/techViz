import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizDialog.dart';

class VizSelector extends StatefulWidget {
  const VizSelector(
      this.title,
      this.options,
      this.onOKTap,
      {Key key,
      this.onBackTap,
      this.multiple = false,
      })
      : super(key: key);

  final String title;
  final bool multiple;
  final Future<bool> Function(BuildContext ctx, List<IVizSelectorOption>) onOKTap;
  final VoidCallback onBackTap;
  final List<IVizSelectorOption> options;

  @override
  State<StatefulWidget> createState() => VizSelectorState(options);
}

class VizSelectorState extends State<VizSelector> {
  Flushbar _loadingBar;
  List<IVizSelectorOption> options;

  VizSelectorState(this.options);

  @override
  void initState() {
    _loadingBar = VizDialog.LoadingBar(message: 'Sending request...');
    super.initState();
  }

  void onOkTap(BuildContext context){
    _loadingBar.show(context);

    List<IVizSelectorOption> selectedOptions = options.where((IVizSelectorOption option) => option.selected).toList();
    widget.onOKTap(context, selectedOptions).then((bool done){
      if(done!=null && done){
        _loadingBar.dismiss();
        Navigator.of(context).maybePop(true);
      }
    }).catchError((dynamic error){
      _loadingBar.dismiss();
      VizDialog.Alert(context, 'Error', error.toString());
    });
  }

  void onBackTap(){
    if(widget.onBackTap!=null)
      widget.onBackTap();

    Navigator.of(context).maybePop(false);
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration defaultBgDeco = BoxDecoration(gradient: LinearGradient(colors: const [Color(0xFF636f7e), Color(0xFF9aa8b0)], begin: Alignment.topCenter, end: Alignment.bottomCenter));

    List<Widget> actions = <Widget>[];
    if (widget.multiple) {
      actions.add(VizButton(title: 'All', onTap: onSelectAllTapped));
      actions.add(VizButton(title: 'None', onTap: onSelectNoneTapped));
    }

    GridView body = GridView.count(
        shrinkWrap: true,
        padding: EdgeInsets.all(4.0),
        childAspectRatio: 1.5,
        addAutomaticKeepAlives: false,
        crossAxisCount: 4,
        children: options.map((final IVizSelectorOption option) {
          return VizOptionButton(
              option.description,
              selected: option.selected,
              onTap: (Object obj){
                selectOption(option);
              });
        }).toList());

    bool canPop = Navigator.canPop(context);

    VizButton leading = canPop ? VizButton(title: 'Back', onTap: onBackTap, highlighted: false) : null;
    VizButton tailing = widget.onOKTap!=null ? VizButton(title: 'OK', onTap: (){
      onOkTap(context);
    }, highlighted: true) : null;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: ActionBar(title: widget.title, titleColor: Colors.blue, leadingWidget: leading, tailWidget: tailing),
        body: Container(
          decoration: defaultBgDeco,
          constraints: BoxConstraints.expand(),
          child: body,
        ),
    );
  }

  void selectOption(IVizSelectorOption selectedOption){
    //SELECT NONE OF THEM
    setState(() {
      options.forEach((IVizSelectorOption option) {
        option.selected = false;
      });

      options.where((IVizSelectorOption option) => option.id == selectedOption.id).first.selected = true;

    });
  }

  void onSelectAllTapped() {
    setState(() {
      //widget.options.map((IVizSelectorOption option) => option.selected == true);
    });
  }

  void onSelectNoneTapped() {
    setState(() {
      //widget.options.map((IVizSelectorOption option) => option.selected == false);
    });
  }
}

abstract class IVizSelectorOption {
  Object id;
  String description;
  bool selected;
}
