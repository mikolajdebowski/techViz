import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/common/LowerCaseTextFormatter.dart';
import 'package:techviz/components/VizAlert.dart';
import 'package:techviz/components/VizLoadingIndicator.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizRainbow.dart';
import 'package:techviz/ui/config.dart';
import 'package:techviz/repository/async/DeviceRouting.dart';
import 'package:techviz/repository/async/MessageClient.dart';
import 'package:techviz/repository/async/UserRouting.dart';
import 'package:techviz/repository/local/userTable.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/ui/roleSelector.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';
import 'package:logging/logging.dart';

class Login extends StatefulWidget {

  static const String USERNAME = 'USERNAME';
  static const String PASSWORD = 'PASSWORD';

  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  bool _isLoading = false;
  bool _loginEnabled = false;
  String _loadingMessage = '...';
  AppInfo appInfo;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'username': null,
    'password': null,
  };

  final usernameAddressController = TextEditingController();
  final passwordAddressController = TextEditingController();
  final FocusNode txtPwdFocusNode = FocusNode();
  final FocusNode btnLoginFocusNode = FocusNode();


  SharedPreferences prefs;


  @override
  void initState() {

    usernameAddressController.addListener(_printUsernameValue);
    passwordAddressController.addListener(_printPasswordValue);

    SharedPreferences.getInstance().then((onValue) {
      prefs = onValue;

      if (prefs.getKeys().contains(Login.USERNAME)) {
        usernameAddressController.text = prefs.getString(Login.USERNAME);
      }

      Utils.isEmulator.then((bool isEmulator){
        if(isEmulator){
          if (prefs.getKeys().contains(Login.PASSWORD)) {
            passwordAddressController.text = prefs.getString(Login.PASSWORD);
          }
        }
      });
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

  Future setupUser(String userID) async{
    Completer<void> _completer = Completer<void>();
    DeviceInfo deviceInfo = await Utils.deviceInfo;

    setState(() {
      _loadingMessage = 'Updating user and device info...';
    });

    Session session = Session();
    await MessageClient().Init();

    var toSendUserStatus = {'userStatusID': 10, 'userID': userID, 'deviceID': deviceInfo.DeviceID }; //FORCE OFF-SHIFT REMOTE
    var toSendDeviceDetails = {'userID': userID, 'deviceID': deviceInfo.DeviceID, 'model': deviceInfo.Model, 'OSName': deviceInfo.OSName, 'OSVersion': deviceInfo.OSVersion };

    var userUpdateFuture = UserRouting().PublishMessage(toSendUserStatus).then<dynamic>((dynamic user) async{
      await UserTable.updateStatusID(userID, "10"); //FORCE OFF-SHIFT LOCALLY
      await session.init(userID);

      return Future<dynamic>.value(user);
    });

    var deviceUpdateFuture = DeviceRouting().PublishMessage(toSendDeviceDetails);

    Future.wait<void>([userUpdateFuture, deviceUpdateFuture]).then((List<dynamic> l){
      _completer.complete();
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }

  void loginTap(dynamic args) async {
    if(_isLoading)
      return;

    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Authenticating...';
    });

    SessionClient client = SessionClient();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String serverUrl = prefs.get(Config.SERVERURL) as String;

    client.init(ClientType.PROCESSOR, serverUrl);

    Future<String> authResponse = client.auth(_formData['username'], _formData['password']);
    authResponse.then((String response) async {

      await prefs.setString(Login.USERNAME, usernameAddressController.text);
      await prefs.setString(Login.PASSWORD, passwordAddressController.text);

      await loadInitialData();
      await setupUser(usernameAddressController.text);

      Future.delayed( Duration(milliseconds:  200), () {
        Navigator.pushReplacement(context, MaterialPageRoute<RoleSelector>(builder: (BuildContext context) => RoleSelector()));
      });
    }).catchError((dynamic error) {
      final Logger log = Logger(toStringShort());
      log.info(error.toString());

      setState(() {
        _isLoading = false;
      });
      VizAlert.Show(context, error.toString());
    });

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

    var backgroundDecoration = BoxDecoration(
        gradient: LinearGradient(
            colors: const [Color(0xFFd6dfe3), Color(0xFFb1c2cb)],
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
            //print('saving username: $value');
          },
          validator: UsernameFieldValidator.validate,
          onEditingComplete: (){
            FocusScope.of(context).requestFocus(txtPwdFocusNode);
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

    final txtPassword = Padding(
      padding: defaultPadding,
      child: TextFormField(
          focusNode: txtPwdFocusNode,
          controller: passwordAddressController,
          onSaved: (String value) {
            //print('saving password: $value');
            _formData['password'] = value;
          },
          autocorrect: false,
          validator: PasswordFieldValidator.validate,
          onEditingComplete: (){
            loginTap(null);
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

    final btnLogin = VizOptionButton('Login', onTap: loginTap, enabled: _loginEnabled, selected: true);

    var btnBox = Padding(
        padding: defaultPadding,
        child: btnLogin);

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


    var configBtn = IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/config');
      },
    );

    var loggingBtn = IconButton(
      icon: Icon(Icons.list),
      onPressed: () {
        Navigator.pushNamed(context, '/logging');
      },
    );

    var topActions = Row(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[
          loggingBtn, configBtn,
          ]);

    var container = Container(
        decoration: backgroundDecoration,
        child: Stack(
          children: <Widget>[
            topActions,
            Align(alignment: Alignment.center, child: loginForm),
            Align(alignment: Alignment.bottomCenter, child: VizRainbow()),
            VizLoadingIndicator(message: _loadingMessage, isLoading: _isLoading)
          ],
        ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: container),
    );
  }

  void _printUsernameValue() {
    _checkIfLoginEnable();
  }

  void _printPasswordValue() {
    _checkIfLoginEnable();
  }

  void _checkIfLoginEnable() {
    if(usernameAddressController.text.isNotEmpty && passwordAddressController.text.isNotEmpty){
      setState(() {
        _loginEnabled = true;
      });
    } else{
      setState(() {
        _loginEnabled = false;
      });
    }

  }

}



class UsernameFieldValidator {
  static String validate(String value){
    return value.isEmpty ? 'Username is required' : null;
  }
}


class PasswordFieldValidator {
  static String validate(String value){
    return value.isEmpty ? 'Password is required' : null;
  }
}
