import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:techviz/common/LowerCaseTextFormatter.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:flutter/services.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizRainbow.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class Config extends StatefulWidget {
  static const String SERVERURL = 'SERVERURL';

  @override
  State<StatefulWidget> createState() => ConfigState();
}

class ConfigState extends State<Config> {
  SharedPreferences prefs;
  final serverAddressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _nextEnabled = false;

  var default_url_options = {
    'protocols': ['Http', 'http', 'Https', 'https'],
    'require_protocol': false,
  };

  void _printUrlValue() {
    if(serverAddressController.text.isNotEmpty){
      setState(() {
        _nextEnabled = true;
      });
    } else{
      setState(() {
        _nextEnabled = false;
      });
    }

  }

  @override
  void initState() {
    serverAddressController.addListener(_printUrlValue);
    SharedPreferences.getInstance().then((onValue) {
      prefs = onValue;
      if (prefs.getKeys().contains(Config.SERVERURL)) {
        serverAddressController.text = prefs.getString(Config.SERVERURL);
      }
    });

    super.initState();
  }

  void onNextTap(dynamic args) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (!serverAddressController.text.toLowerCase().contains('http')) {
        serverAddressController.text = 'http://${serverAddressController.text}';
      }

      await prefs.setString(Config.SERVERURL, serverAddressController.text);

      if(Navigator.of(context).canPop()){
        Navigator.pop(context);
      }else{
        Navigator.pushReplacementNamed(context, '/login');
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    var textFieldStyle = TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: 20.0,
        color: Color(0xFFffffff),
        fontWeight: FontWeight.w500,
        fontFamily: "Roboto");

    var textFieldBorder = OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));
    var defaultPadding = EdgeInsets.all(6.0);
    var textFieldContentPadding = EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0);

    var hintTextFieldStyle = TextStyle(fontStyle: FontStyle.italic,
        fontSize: 20.0,
        color: Color(0xFFE0E0E0),
        fontWeight: FontWeight.w500,
        fontFamily: "Roboto");

    var backgroundDecoration = BoxDecoration(
        gradient: LinearGradient(
            colors: const [Color(0xFFd6dfe3), Color(0xFFb1c2cb)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.repeated));

    var textField = Padding(
        padding: defaultPadding,
        child: TextFormField(
            inputFormatters: [LowerCaseTextFormatter()],
            onSaved: (String value) {
              print('saving url: $value');
            },
            autocorrect: false,
            validator: (String value) {
              if (!Validator.isUrl(value, default_url_options)) {
                return 'Please enter valid URL';
              }
              return null;
            },
            controller: serverAddressController,
            decoration: InputDecoration(
                fillColor: Colors.black87,
                filled: true,
                hintStyle: hintTextFieldStyle,
                hintText: 'Server Address',
                border: textFieldBorder,
                contentPadding: textFieldContentPadding),
            style: textFieldStyle));

    var formColumn = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              child: Form(
            key: _formKey,
            child: textField,
          )),
          Text(
            'Your server address needs to be set before you can login for the first time.',
            style: TextStyle(color: Color(0xff474f5b)),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );

    var row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(child: formColumn),
      ],
    );

    var container = Container(
        decoration: backgroundDecoration,
        child: Stack(
          children: <Widget>[
            Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(child:Container(
                    height: 110.0,
                    child: row,
                  )),
                )),
            Align(alignment: Alignment.bottomCenter, child: VizRainbow()),
          ],
        ));

    VizButton okBtn = VizButton(title: 'OK', highlighted: true, onTap: () => onNextTap(context), enabled: _nextEnabled);
    return Scaffold(backgroundColor: Colors.black, appBar: ActionBar(title: 'Server configuration', tailWidget: okBtn), body: SafeArea(child: container), );
  }
}
