import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:techviz/components/vizElevated.dart';
import 'package:techviz/login.dart';
import 'package:validator/validator.dart';

class Config extends StatefulWidget {
  static final String SERVERURL = 'SERVERURL';

  @override
  State<StatefulWidget> createState() => ConfigState();
}

class ConfigState extends State<Config> {
  SharedPreferences prefs;
  final serverAddressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var default_url_options = {
    'protocols': ['Http', 'http', 'Https', 'https'],
    'require_protocol': false,
  };

  @override
  void initState() {
    SharedPreferences.getInstance().then((onValue) {
      prefs = onValue;
      if (prefs.getKeys().contains(Config.SERVERURL)) {
        serverAddressController.text = prefs.getString(Config.SERVERURL);
      }
    });

    super.initState();
  }

  void onNextTap() async {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      await prefs.setString(Config.SERVERURL, serverAddressController.text);

      Navigator.push<Login>(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

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
                                        onSaved: (String value){
                                          print('saving url: $value');
                                        },
                                        autocorrect: false,
                                        validator: (String value) {
                                          if (!isURL(value, default_url_options)) {
                                            return 'Please enter valid URL';
                                          }
                                        },
                                        controller: serverAddressController,
                                        decoration: InputDecoration(
                                            fillColor: Colors.black87,
                                            filled: true,
                                            hintStyle: textFieldStyle,
                                            hintText: 'Server Address',
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
                                onTap: onNextTap,
                                title: 'Next',
                                customBackground: [Color(0xFFFFFFFF), Color(0xFFAAAAAA)]))
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}
