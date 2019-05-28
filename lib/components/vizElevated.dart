import 'package:flutter/material.dart';

class VizElevated extends StatefulWidget {
  VizElevated(
      {Key key,
      this.title,
      this.onTap,
      this.textColor,
      this.customWidget,
      this.customBackground,
      this.customBorderColor,
      this.selectable = false,
      this.selected = false})
      : super(key: key);

  final VoidCallback onTap;
  final String title;
  final Color textColor;
  final Widget customWidget;
  final List<Color> customBackground;
  final Color customBorderColor;
  final bool selectable;
  final bool selected;

  @override
  State<StatefulWidget> createState() {
    return VizElevatedState(selected: selected);
  }
}

class VizElevatedState extends State<VizElevated> {
  VizElevatedState({this.selected});

  bool selected = false;

  void onSelect() {
    setState(() {
      selected = !selected;
    });
  }

  @override
  Widget build(BuildContext context) {

    TextStyle defaultTextStyle = TextStyle(
        color:  Color(0xFF495666),
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 22.0);

    Widget innerWidget;
    if (widget.customWidget != null) {
      innerWidget = widget.customWidget;
    } else {
      if (widget.textColor != null) {
        innerWidget = Text(widget.title,
            textAlign: TextAlign.center,
            style: defaultTextStyle.copyWith(color: widget.textColor));
      } else {
        innerWidget = Text(widget.title,
            textAlign: TextAlign.center, style: defaultTextStyle);
      }
    }

    LinearGradient gradient;
    if (widget.customBackground == null) {
      var _colors = [
         Color(0xFFE4EDEF),
         Color(0xFFB1C6CF),
      ];

      if (selected) {
        _colors = [ Color(0xFF0c72ba), Color(0xFF0c72ba)];
      }

      gradient = LinearGradient(
          colors: _colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.repeated);
    } else {
      gradient = LinearGradient(
          colors: widget.customBackground,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.repeated);
    }

    Border borderColor;
    if(widget.customBorderColor != null){
      borderColor = Border.all(color: widget.customBorderColor); //default
    }
    else{
      borderColor = Border.all(color: Color(0xFFEEEEEE)); //default
    }

    BoxDecoration boxDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          border: borderColor,
          gradient: gradient);


    var container = Container(
      margin: EdgeInsets.all(2.0),
      decoration: boxDecoration,
      child: Center(
        child: innerWidget,
      ),
    );

    VoidCallback onTapEventToCall;
    if (widget.selectable) {
      onTapEventToCall = onSelect;
    } else {
      onTapEventToCall = widget.onTap;
    }

    var tapper = GestureDetector(
      child: container,
      onTap: onTapEventToCall,
    );

    return tapper;
  }
}
