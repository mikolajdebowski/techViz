import 'dart:async';

import 'package:flutter/material.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/home.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
//  final _usernameController = TextEditingController();
//  final _passwordController = TextEditingController();

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'username': null,
    'password': null,
  };

  Future<Map<String, String>> login(String username, String password) async {
    final Map<String, String> authData = {
      'username': username,
      'password': password,
    };

//    final http.Response response = await http.post(
//        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDNbb2X-TjJpOGEehhdET9ClHFR1ReyBvU',
//        body: json.encode(authData));
//
//    print(json.decode(response.body));



    return {'success': 'true', 'message': 'Authentication succeeded!'};
  }

  void fetchProducts() {
    http.get('https://flutter-products-f7291.firebaseio.com/products.json').then((http.Response response) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
    });
  }

  void loginTap() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      final Map<String, dynamic> info = await login(_formData['username'], _formData['password']);
      if (info['success'] as bool) {
        Navigator.push<Home>(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          child: Form(
                            key: _formKey,
                            child: Container(
                              width: 400.0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: textFieldPadding,
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
//                                      controller: _usernameController,
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                            width: 110.0,
                            height: 110.0,
                            child: VizElevated(
                                onTap: loginTap,
                                title: 'Login',
                                customBackground: [Color(0xFFFFFFFF), Color(0xFFAAAAAA)]))
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}
