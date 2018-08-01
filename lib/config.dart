import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:techviz/common/LowerCaseTextFormatter.dart';
import 'package:techviz/components/VizButton.dart';
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

      if (!serverAddressController.text.toLowerCase().contains('http')) {
        serverAddressController.text = 'http://${serverAddressController.text}';
      }

      await prefs.setString(Config.SERVERURL, serverAddressController.text);
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    var textFieldStyle = TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: 20.0,
        color: Color(0xFFffffff),
        fontWeight: FontWeight.w500,
        fontFamily: "Roboto");

    var textFieldBorder = OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));
    var defaultPadding = EdgeInsets.all(7.0);
    var textFieldContentPadding = new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0);

    var backgroundDecoration = BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFFd6dfe3), Color(0xFFb1c2cb)],
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
            style: textFieldStyle));


    var btnNext = VizButton('Next', onTap: onNextTap, highlighted: true);

    final colors = <Color>[
      Color(0xFFd6de27),
      Color(0xFF96c93f),
      Color(0xFF09a593),
      Color(0xFF0c7dc2),
      Color(0xFF564992),
      Color(0xFFea1c42),
      Color(0xFFf69320),
      Color(0xFFfedd00)
    ];

    var rainbow = Container(
      height: 10.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight, // 10% of the width, so there are ten blinds.
          colors: colors,
//          stops: colorStops// repeats the gradient over the canvas
        ),
      ),
    );



    var btnBox = Padding(padding: defaultPadding, child: SizedBox(
        height: 45.0,
        width: 100.0,
        child: Flex(
            direction: Axis.horizontal, children: <Widget>[btnNext])));

    var formColumn = Expanded(
      child: Column(
        children: <Widget>[
          Flexible(child: Form(
            key: _formKey,
            child: textField,
          )),
          Text(
            'Your server address needs to be set before you can login for the first time.',
            style: TextStyle(color: Color(0xff474f5b)),textAlign: TextAlign.center,
          )
        ],
      ),
    );

    var row = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[Container(width: 40.0,),formColumn,btnBox],
    );

    return Scaffold(
        body: Container(
            decoration: backgroundDecoration,
            child: Stack(
              children: <Widget>[
                Align(alignment: Alignment.center, child: Container(height: 100.0, child: row,)),
                Align(alignment: Alignment.bottomCenter, child: rainbow),
              ],
            )));
  }
}
