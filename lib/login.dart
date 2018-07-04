import 'package:flutter/material.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/home.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    var textFieldStyle = TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: 28.0,
        color: Color(0xFFffffff),
        fontWeight: FontWeight.w500,
        fontFamily: "Roboto");

    var textFieldBorder = OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));
    var textFieldPadding = EdgeInsets.only(bottom: 5.0);
    var textFieldContentPadding = new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0);

    var backgroundDecoration = BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFFd6dfe3), Color(0xFFb1c2cb)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.repeated));

    void onNextTap() async {
      Navigator.push<Home>(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );

    }

    return Scaffold(
        body: Container(
            decoration: backgroundDecoration,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Container(
                            width: 400.0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: textFieldPadding,
                                  child: TextField(
                                      decoration: InputDecoration(
                                          fillColor: Colors.black87,
                                          filled: true,
                                          hintStyle: textFieldStyle,
                                          hintText: 'Username',
                                          border: textFieldBorder,
                                          contentPadding: textFieldContentPadding),
                                      style: textFieldStyle),
                                ),
                                Padding(
                                  padding: textFieldPadding,
                                  child: TextField(
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          fillColor: Colors.black87,
                                          filled: true,
                                          hintText: 'Password',
                                          hintStyle: textFieldStyle,
                                          border: textFieldBorder,
                                          contentPadding: textFieldContentPadding),
                                      style: textFieldStyle),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                            width: 110.0,
                            height: 110.0,
                            child: VizElevated(
                                onTap: onNextTap,
                                title: 'Login',
                                customBackground: [Color(0xFFFFFFFF), Color(0xFFAAAAAA)]))
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  void buttonPressed() {}
}
