import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/common/LowerCaseTextFormatter.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/appInfo.dart';
import 'package:techviz/common/http/client/processorClient.dart';
import 'package:techviz/common/http/client/sessionClient.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/common/slideRightRoute.dart';
import 'package:techviz/common/utils.dart';
import 'package:techviz/components/VizAlert.dart';
import 'package:techviz/components/VizLoadingIndicator.dart';
import 'package:techviz/components/VizOptionButton.dart';
import 'package:techviz/components/vizRainbow.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/service/deviceService.dart';
import 'package:techviz/service/taskService.dart';
import 'package:techviz/ui/config.dart';
import 'package:techviz/repository/async/MessageClient.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/session.dart';
import 'package:techviz/ui/roleSelector.dart';
import 'package:logging/logging.dart';

class Login extends StatefulWidget {

  static const String USERNAME = 'USERNAME';
  static const String PASSWORD = 'PASSWORD';

  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  bool _isLoading = false;
  String _loadingMessage = '...';
  AppInfo appInfo;
  bool _loginEnabled;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'username': null,
    'password': null,
  };

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode txtPwdFocusNode = FocusNode();
  final FocusNode btnLoginFocusNode = FocusNode();


  SharedPreferences prefs;

  @override
  void initState() {

    usernameController.addListener(_checkIfLoginEnable);
    passwordController.addListener(_checkIfLoginEnable);

    SharedPreferences.getInstance().then((onValue) {
      prefs = onValue;

      if (prefs.getKeys().contains(Login.USERNAME)) {
        usernameController.text = prefs.getString(Login.USERNAME);
      }

      DeviceUtils().init().then((DeviceInfo info){
        if(info.isEmulator){
          if (prefs.getKeys().contains(Login.PASSWORD)) {
            passwordController.text = prefs.getString(Login.PASSWORD);
          }
        }
      });
    });

    getAppInfo();

    super.initState();
    _checkIfLoginEnable();
  }


  void getAppInfo() {
    Utils.packageInfo.then((AppInfo info){
      setState(() {
        appInfo = info;
      });
    });

  }


  Future<void> fetchInitialData() async{
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

  Future updateDeviceInfo() async{
    setState(() {
      _loadingMessage = 'Updating device info...';
    });

    await DeviceService().update(Session().user.userID).catchError((dynamic error){
      if(error is TimeoutException){
        throw Exception('A timeout exception has been thrown. Please try again.');
      }
    });
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

    client.init(ProcessorClient(serverUrl));

    Future<String> authResponse = client.auth(_formData['username'], _formData['password']);
    authResponse.then((String response) async {

      await prefs.setString(Login.USERNAME, usernameController.text);
      await prefs.setString(Login.PASSWORD, passwordController.text);

      await fetchInitialData();

      Session().init(usernameController.text);

      //INIT MQTTClient Service
      String broker = serverUrl.replaceAll('http://', '').replaceAll('https://', '');
      String deviceID = DeviceUtils().deviceInfo.DeviceID;
      await MQTTClientService().init(broker, deviceID, logging: false);
      await MQTTClientService().connect();

      TaskService().listenAsync();

      //INIT AMQP MessageClient
      await MessageClient().Connect();
      await updateDeviceInfo();


      //INIT DEFAULT LISTENERS
      Repository().startServices();

      Navigator.pushReplacement(context, MaterialPageRoute<RoleSelector>(builder: (BuildContext context) => RoleSelector()));

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

    TextStyle textFieldStyle = TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: 20.0,
        color: Color(0XFFFFFFFF),
        fontWeight: FontWeight.w500,
        fontFamily: "Roboto");

    TextStyle hintTextFieldStyle = TextStyle(fontStyle: FontStyle.italic,
        fontSize: 20.0,
        color: Color(0X66FFFFFF),
        fontWeight: FontWeight.w500,
        fontFamily: "Roboto");

    OutlineInputBorder textFieldBorder = OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));
    EdgeInsets defaultPadding = EdgeInsets.all(6.0);
    EdgeInsets textFieldContentPadding = EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0);

    BoxDecoration backgroundDecoration = BoxDecoration(
        gradient: LinearGradient(
            colors: const [Color(0xFFd6dfe3), Color(0xFFb1c2cb)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.repeated));

    Padding txtFieldUser = Padding(
      padding: defaultPadding,
      child: TextFormField(
          controller: usernameController,
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
              hintStyle: hintTextFieldStyle,
              hintText: 'Username',
              border: textFieldBorder,
              contentPadding: textFieldContentPadding),
          style: textFieldStyle),
    );

    final txtPassword = Padding(
      padding: defaultPadding,
      child: TextFormField(
          focusNode: txtPwdFocusNode,
          controller: passwordController,
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
              hintStyle: hintTextFieldStyle,
              border: textFieldBorder,
              contentPadding: textFieldContentPadding),
          style: textFieldStyle),
    );

    final VizOptionButton btnLogin = VizOptionButton('Login', onTap: loginTap, enabled: _loginEnabled, selected: true);

    Padding btnBox = Padding(
        padding: defaultPadding,
        child: btnLogin);

    Column loginForm = Column(
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


    IconButton configBtn = IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        Navigator.push<Login>(
          context,
          SlideRightRoute(widget: Config()),
        );
      },
    );

    IconButton loggingBtn = IconButton(
      icon: Icon(Icons.list),
      onPressed: () {
        Navigator.pushNamed(context, '/logging');
      },
    );

    Row topActions = Row(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[
        configBtn, loggingBtn,
    ]);

    Container container = Container(
        decoration: backgroundDecoration,
        child: Stack(
          children: <Widget>[
            topActions,
            Align(alignment: Alignment.center,
              child: SingleChildScrollView(child: loginForm),
            ),
            Align(alignment: Alignment.bottomCenter, child: VizRainbow()),
            VizLoadingIndicator(message: _loadingMessage, isLoading: _isLoading)
          ],
        ));


    return Scaffold(backgroundColor: Colors.black, body: SafeArea(child: container));
  }

  void _checkIfLoginEnable() {
    setState(() {
      _loginEnabled = usernameController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
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