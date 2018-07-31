import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:techviz/common/LowerCaseTextFormatter.dart';
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
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if(!serverAddressController.text.toLowerCase().contains('http')){
        serverAddressController.text = 'http://${serverAddressController.text}';
      }

      await prefs.setString(Config.SERVERURL, serverAddressController.text);
      Navigator.pushReplacementNamed(context, '/login');
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

    var textField = Padding(
        padding: defaultPadding,
        child: TextFormField(
            inputFormatters: [LowerCaseTextFormatter()],
            onSaved: (String value) {
              print('saving url: $value');
            },
            autocorrect: false,
            validator: (String value) {
              if (!isURL(value, default_url_options)) {
                return 'Please enter valid URL';
              }
            },
            controller: serverAddressController,
            decoration:
                InputDecoration(fillColor: Colors.black87, filled: true, hintStyle: textFieldStyle, hintText: 'Server Address', border: textFieldBorder, contentPadding: textFieldContentPadding),
            style: textFieldStyle));

    var btnNext = Padding(padding: defaultPadding, child: VizElevated(onTap: onNextTap, title: 'Next', customBackground: [Color(0xFFFFFFFF), Color(0xFFAAAAAA)]));

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
                        child: textField,
                      )),
                  Expanded(
                    child: Container(height: 60.0, child: btnNext),
                  ),
                ],
              ),
            )));

  }
}
