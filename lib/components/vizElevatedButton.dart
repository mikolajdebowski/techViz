import 'package:flutter/material.dart';

class VizElevatedButton extends StatefulWidget {
  VizElevatedButton({Key key, this.title, this.onTap, this.textColor, this.customWidget, this.customBackground, this.selectable = false, this.selected = false}) : super(key: key);

  final VoidCallback onTap;
  final String title;
  final Color textColor;
  final Widget customWidget;
  final List<Color> customBackground;
  final bool selectable;
  final bool selected;

  @override
  State<StatefulWidget> createState() {
    return new VizElevatedButtonState(selected: this.selected);
  }

}

class VizElevatedButtonState extends State<VizElevatedButton>{

  VizElevatedButtonState({this.selected});

  bool selected = false;

  void onSelect(){
    setState(() {
      selected = !selected;
    });
  }


  @override
  Widget build(BuildContext context) {

    const TextStyle defaultTextStyle = const TextStyle(
        color: Colors.white,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 22.0);

    var innerWidget;
    if(widget.customWidget != null){
      innerWidget = widget.customWidget;
    }
    else {
      if(widget.textColor != null){
        innerWidget = new Text(widget.title, textAlign: TextAlign.center, style: defaultTextStyle.copyWith(color: widget.textColor));
      }
      else{
        innerWidget = new Text(widget.title, textAlign: TextAlign.center, style: defaultTextStyle);
      }
    }

    var gradient;
    if(widget.customBackground == null){

      var _colors =  [ //default color
        const Color(0xFF252930),
        const Color(0xFF1a1b1f),
      ];

      if(selected){
        _colors = [const Color(0xFF0c72ba), const Color(0xFF0c72ba)];
      }

      gradient = new LinearGradient(
          colors: _colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.repeated);
    }
    else {
      gradient = new LinearGradient(
          colors: widget.customBackground,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          tileMode: TileMode.repeated);
    }

    var boxDecoration = new BoxDecoration(
        borderRadius: new BorderRadius.circular(4.0),
        border: new Border.all(color: const Color(0xFF333333)),
        gradient: gradient);


    var container = new Container(
      margin: const EdgeInsets.all(2.0),
      decoration: boxDecoration,
      child: new Center(
        child: innerWidget,
      ),
    );

    VoidCallback onTapEventToCall;
    if(widget.selectable){
      onTapEventToCall = onSelect;
    }
    else{
      onTapEventToCall = widget.onTap;
    }

    var tapper = new GestureDetector(
      child: container,
      onTap: onTapEventToCall,
    );

    return tapper;
  }

}
