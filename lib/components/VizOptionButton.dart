import 'package:flutter/material.dart';

typedef OptionCallback = void Function(String);

class VizOptionButton extends StatelessWidget {
  VizOptionButton(this.title, {
        this.tag,
        this.onTap,
        this.flex = 1,
        this.flexible = false,
        this.selected = false,
        this.iconName,
        this.enabled = true})
      : super();

  final OptionCallback onTap;
  final String title;
  final bool selected;
  final String iconName;
  final int flex;
  final bool flexible;
  final String tag;
  final bool enabled;

  @override
  Widget build(BuildContext context) {

    Text innerText = Text(title, style: selected ? HighlightedTextStyle: DefaultTextStyle, textAlign: TextAlign.center);

    Widget innerWidget = null;
    if(iconName==null){
      innerWidget = innerText;
    }
    else{
      Image icon = Image(image: AssetImage('assets/images/${iconName}'), height: 30.0,);
      innerWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[icon,Padding(child: innerText, padding: EdgeInsets.only(left: 10.0))],
      );
    }

    var btn = Padding(
      child: GestureDetector(
        onTap: onTapFnc,
        child: Container(
            constraints: BoxConstraints.expand(),
            decoration: enabled == false? DisabledBoxDecoration : (selected ? HighlightedBoxDecoration: DefaultBoxDecoration),
            child: Center(child: innerWidget)
        ),
      ),
      padding: EdgeInsets.all(3.0),
    );

    if(flexible){
      return Flexible(
          fit: FlexFit.tight,
          flex: flex,
          child: btn
      );
    }
    return btn;
  }


  void onTapFnc(){
    if(!enabled)
      return;

    if(onTap!=null){
      onTap(tag);
    }
  }

  TextStyle get DefaultTextStyle{
    return TextStyle(color: Color(0xFF474f5b), fontSize: 14.0);
  }

  TextStyle get HighlightedTextStyle{
    return TextStyle(color: Color(0xFFFFFFFF), fontSize: 14.0);
  }

  BoxDecoration get DefaultBoxDecoration{
    return BoxDecoration(
        boxShadow: [BoxShadow(color: Color(0xAA000000), offset: Offset(3.0, 3.0), blurRadius: 3.0)],
        gradient: LinearGradient(
            colors: [Color(0xFFBDCCD4), Color(0xFFEBF0F2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(4.0));
  }

  BoxDecoration get DisabledBoxDecoration{
    return BoxDecoration(
        boxShadow: [BoxShadow(color: Color(0xAA000000), offset: Offset(3.0, 3.0), blurRadius: 3.0)],
        gradient: LinearGradient(
            colors: [Color(0xFF888888), Color(0xFFAAAAAA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(4.0));
  }

  BoxDecoration get HighlightedBoxDecoration{
    return BoxDecoration(
        boxShadow: [BoxShadow(color: Color(0xAA000000), offset: Offset(3.0, 2.0), blurRadius: 3.0)],
        gradient: LinearGradient(
            colors: [Color(0xFF66B5E1), Color(0xFF0C7DC2), Color(0xFF00649C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(4.0));
  }
}

