import 'package:flutter/material.dart';

class VizButton extends StatelessWidget {
  const VizButton({Key key, this.title, this.onTap, this.flex = 1, this.iconName, this.highlighted = false, this.enabled = true, this.customWidget})
      : super(key: key);

  final VoidCallback onTap;
  final String title;
  final String iconName;
  final int flex;
  final bool highlighted;
  final Widget customWidget;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    Color txtDefaultColor = Color(0xFF636f7e);
    Color txtHighlightColor = Colors.white;

    Widget innerWidget;
    if (customWidget != null) {
      innerWidget = customWidget;
    } else {
      Text innerText = Text(title, style: TextStyle(color: highlighted ? txtHighlightColor : txtDefaultColor, fontSize: 20.0, fontWeight: FontWeight.w500));
      if (iconName == null) {
        innerWidget = innerText;
      } else {
        Image icon = Image(
          image: AssetImage('assets/images/$iconName'),
          height: 30.0,
        );
        innerWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[icon, Padding(child: innerText, padding: EdgeInsets.only(left: 10.0))],
        );
      }
    }

    bool clickable = true;

    return Flexible(
        fit: FlexFit.tight,
        flex: flex,
        child: Container(
            margin: EdgeInsets.all(3.0),
            constraints: BoxConstraints.expand(),
            decoration: DefaultBoxDecoration,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (clickable) onTap();

                  clickable = false;
                  Future<void>.delayed(const Duration(seconds: 1), () {
                    clickable = true;
                  });
                },
                child: Center(
                  child: innerWidget,
                ),
              ),
            )
        )
    );
  }

  BoxDecoration get DefaultBoxDecoration {
    List<Color> defaultBg = [Color(0xFFebf0f2), Color(0xFFbdccd4)];
    List<Color> highlightBg = [Color(0xFF96c93f), Color(0xFF09a593)];
    List<Color> disabledBg = [Color(0xFFD3D3D3), Color(0xFFD3D3D3)];

    return BoxDecoration(
        boxShadow: const [BoxShadow(color: Color(0xFF666666), offset: Offset(1.0, 1.0), blurRadius: 1.0)],
        gradient: LinearGradient(
            colors: enabled == false ? disabledBg : (highlighted ? highlightBg : defaultBg), begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(3.0));
  }
}
