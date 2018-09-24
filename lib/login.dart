import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/common/LowerCaseTextFormatter.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/VizLoadingIndicator.dart';
import 'package:techviz/components/vizRainbow.dart';
import 'package:techviz/config.dart';
import 'package:techviz/repository/rabbitmq/channel/deviceChannel.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:techviz/roleSelector.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class Login extends StatefulWidget {

  static final String USERNAME = 'USERNAME';
  static final String PASSWORD = 'PASSWORD';

  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  bool _isLoading = false;
  String _loadingMessage = '...';
  AppInfo appInfo;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'username': null,
    'password': null,
  };

  final usernameAddressController = TextEditingController();
  final passwordAddressController = TextEditingController();

  SharedPreferences prefs;

  @override
  void initState() {

    SharedPreferences.getInstance().then((onValue) {
      prefs = onValue;

      if (prefs.getKeys().contains(Login.USERNAME)) {
        usernameAddressController.text = prefs.getString(Login.USERNAME);
      }

      //if(Utils.isDebug){
        if (prefs.getKeys().contains(Login.PASSWORD)) {
          passwordAddressController.text = prefs.getString(Login.PASSWORD);
        }
      //}
    });

    getAppInfo();

    super.initState();
  }


  void getAppInfo() {
    Utils.packageInfo.then((AppInfo info){
      setState(() {
        appInfo = info;
      });
    });

  }


  Future<void> loadInitialData() async{
    Repository repo = Repository();
    await repo.configure(Flavor.PROCESSOR);

    void onMessage(String message){
      setState(() {
        _loadingMessage = message;
      });
    }

    await repo.preFetch(onMessage);
    await repo.initialFetch(onMessage);
  }

  Future<void> setupUser() async{

    //CREATE SESSION
    Session session = Session();
    session.user = await UserRepository().getUser();

    DeviceInfo deviceInfo = await Utils.deviceInfo;
    String userID = session.user.UserID;

    var toSend = {'userID': userID, 'deviceID': deviceInfo.DeviceID, 'model': deviceInfo.Model, 'OSName': deviceInfo.OSName, 'OSVersion': deviceInfo.OSVersion };

    DeviceChannel deviceChannel = DeviceChannel();
    await deviceChannel.submit(toSend);
  }

  void loginTap() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
        _loadingMessage = 'Authenticating...';
      });

      SessionClient client = SessionClient.getInstance();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String serverUrl = prefs.get(Config.SERVERURL) as String;

      client.init(ClientType.PROCESSOR, serverUrl);

      Future<String> authResponse = client.auth(_formData['username'], _formData['password']);
      authResponse.then((String response) async {

        await prefs.setString(Login.USERNAME, usernameAddressController.text);
        await prefs.setString(Login.PASSWORD, passwordAddressController.text);

        await loadInitialData();
        await setupUser();

        Future.delayed( Duration(milliseconds:  200), () {
          Navigator.pushReplacement(context, MaterialPageRoute<RoleSelector>(builder: (BuildContext context) => RoleSelector()));
        });
      }).catchError((Object error) {
        setState(() {
          _isLoading = false;
        });
        showModalBottomSheet<String>(
            context: context,
            builder: (BuildContext context) {
              return Center(
                  child: Padding(
                    padding: EdgeInsets.all(80.0),
                    child: Text(error.toString()),
                  ));
            });
      });
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
    var textFieldContentPadding = new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0);

    var backgroundDecoration = BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFFd6dfe3), Color(0xFFb1c2cb)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.repeated));

    var txtFieldUser = Padding(
      padding: defaultPadding,
      child: TextFormField(
          controller: usernameAddressController,
          inputFormatters: [LowerCaseTextFormatter()],
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
          controller: passwordAddressController,
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

    var btnLogin = VizButton(title: 'Login', onTap: loginTap, highlighted: false);

    var btnBox = Padding(
        padding: defaultPadding,
        child: SizedBox(
            height: 45.0,
            width: 100.0,
            child: Flex(direction: Axis.horizontal, children: <Widget>[btnLogin])));

    var loginForm = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              flex: 4,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[txtFieldUser, txtPassword],
                ),
              )),
          Expanded(
            child: Container(height: 120.0, child: btnBox),
          ),
        ],
      ),
      Text(
        appInfo!=null? 'Version ${appInfo.version} (Build ${appInfo.buildNumber})': '',
        style: TextStyle(color: Color(0xff474f5b)),
        textAlign: TextAlign.center,
      )
      ],

    );

    return Scaffold(
      body: Container(
            decoration: backgroundDecoration,
            child: Stack(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top:20.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/config');
                        },
                      ),
                    )),
                Align(alignment: Alignment.center, child: loginForm),
                Align(alignment: Alignment.bottomCenter, child: VizRainbow()),
                VizLoadingIndicator(message: _loadingMessage, isLoading: _isLoading)
              ],
            )),
    );
  }
}
