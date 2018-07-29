import 'dart:async';

import 'package:flutter/material.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/home.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:techviz/loader.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'username': null,
    'password': null,
  };


  void loginTap() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      //final Map<String, String> info = await login(_formData['username'], _formData['password']);



      Navigator.push<Home>(
        context,
        MaterialPageRoute(builder: (context) => Loader()),
      );


    }
  }

  @override
  Widget build(BuildContext context) {

    var textFieldStyle = TextStyle(fontStyle: FontStyle.italic, fontSize: 20.0, color: Color(0xFFffffff), fontWeight: FontWeight.w500, fontFamily: "Roboto");

    var textFieldBorder = OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));
    var defaultPadding = EdgeInsets.all(7.0);
    var textFieldContentPadding = new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0);

    var backgroundDecoration =
    BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFd6dfe3), Color(0xFFb1c2cb)], begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.repeated));

    var txtFieldUser = Padding(
        padding: defaultPadding,
        child: TextFormField(
            autocorrect: false,
            onSaved: (String value) {
              _formData['username'] = value;
              print('saving username: $value');
            },
            validator: (String value) {
              if (value.isEmpty) {
                return 'Username is required';
              }
            },
            decoration: InputDecoration(
                fillColor: Colors.black87,
                filled: true,
                hintStyle: textFieldStyle,
                hintText: 'Username',
                border: textFieldBorder,
                contentPadding: textFieldContentPadding),
            style: textFieldStyle),
    );

    var txtPassword = Padding(
      padding: defaultPadding,
      child: TextFormField(
          onSaved: (String value) {
            print('saving password: $value');
            _formData['password'] = value;
          },
          autocorrect: false,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Password is required';
            }
          },
//                                      controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
              fillColor: Colors.black87,
              filled: true,
              hintText: 'Password',
              hintStyle: textFieldStyle,
              border: textFieldBorder,
              contentPadding: textFieldContentPadding),
          style: textFieldStyle),
    );

    var btnLogin = Padding(padding: defaultPadding, child: VizElevated(onTap: loginTap, title: 'Login', customBackground: [Color(0xFFFFFFFF), Color(0xFFAAAAAA)]));

    return Scaffold(
        body: Container(
            decoration: backgroundDecoration,
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      flex: 5,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            txtFieldUser, txtPassword
                          ],
                        ),
                      )),
                  Expanded(
                    child: Container(height: 60.0, child: btnLogin),
                  ),
                ],
              ),
            )));


//
//
//    return Scaffold(
//        body: Container(
//            decoration: backgroundDecoration,
//            child: Center(
//              child: Column(
//                mainAxisSize: MainAxisSize.min,
//                mainAxisAlignment: MainAxisAlignment.center,
//                crossAxisAlignment: CrossAxisAlignment.center,
//                children: <Widget>[
//                  Container(
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        Padding(
//                          padding: EdgeInsets.only(right: 10.0),
//                          child: Form(
//                            key: _formKey,
//                            child: Container(
//                              width: 400.0,
//                              child: Column(
//                                mainAxisSize: MainAxisSize.min,
//                                mainAxisAlignment: MainAxisAlignment.center,
//                                crossAxisAlignment: CrossAxisAlignment.center,
//                                children: <Widget>[
//                                  Padding(
//                                    padding: textFieldPadding,
//                                    child: TextFormField(
//                                        autocorrect: false,
//                                        onSaved: (String value) {
//                                          _formData['username'] = value;
//                                          print('saving username: $value');
//                                        },
//                                        validator: (String value) {
//                                          if (value.isEmpty) {
//                                            return 'Username is required';
//                                          }
//                                        },
////                                      controller: _usernameController,
//                                        decoration: InputDecoration(
//                                            fillColor: Colors.black87,
//                                            filled: true,
//                                            hintStyle: textFieldStyle,
//                                            hintText: 'Username',
//                                            border: textFieldBorder,
//                                            contentPadding: textFieldContentPadding),
//                                        style: textFieldStyle),
//                                  ),
//                                  Padding(
//                                    padding: textFieldPadding,
//                                    child: TextFormField(
//                                        onSaved: (String value) {
//                                          print('saving password: $value');
//                                          _formData['password'] = value;
//                                        },
//                                        autocorrect: false,
//                                        validator: (String value) {
//                                          if (value.isEmpty) {
//                                            return 'Password is required';
//                                          }
//                                        },
////                                      controller: _passwordController,
//                                        obscureText: true,
//                                        decoration: InputDecoration(
//                                            fillColor: Colors.black87,
//                                            filled: true,
//                                            hintText: 'Password',
//                                            hintStyle: textFieldStyle,
//                                            border: textFieldBorder,
//                                            contentPadding: textFieldContentPadding),
//                                        style: textFieldStyle),
//                                  ),
//                                ],
//                              ),
//                            ),
//                          ),
//                        ),
//                        Container(
//                            width: 110.0,
//                            height: 110.0,
//                            child: VizElevated(
//                                onTap: loginTap,
//                                title: 'Login',
//                                customBackground: [Color(0xFFFFFFFF), Color(0xFFAAAAAA)]))
//                      ],
//                    ),
//                  ),
//                ],
//              ),
//            )));
  }
}
