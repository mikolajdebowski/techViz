import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/common/http/exception/VizTimeoutException.dart';
import 'client.dart';

class ProcessorClient implements IHttpClient {

  static const Duration defaultTimeoutForAuth = Duration(seconds: 30);
  static const Duration defaultTimeoutForPulling = Duration(seconds: 30);

  String _serverUrl;

  ProcessorClient(String serverURL) {
    _serverUrl = serverURL + '/rest';
  }

  Future<String> getConfig() async {
    Completer<String> _completer = Completer<String>();
    return _completer.future;
  }

  Map<String,String> builderHeader({Map<String,String> toAdd}){
    var defaultHeader = {'User-Agent':'flutter'};

    if(toAdd!=null)
      defaultHeader.addAll(toAdd);

    return defaultHeader;
  }

  @override
  Future<String> auth(String user, String pwd) async {
    Completer<String> _completer = Completer<String>();
    await disconnect();

    http.Client client= http.Client();
    client.get("$_serverUrl/user.json", headers: builderHeader()).timeout(defaultTimeoutForAuth).then((http.Response responseUser) {
      if(responseUser.statusCode == 503)
        throw Exception(responseUser.reasonPhrase);
      String cookie = responseUser.headers['set-cookie'];

      var header = builderHeader(toAdd: {'Content-Type': 'application/x-www-form-urlencoded', 'cookie': cookie});
      var formData = "j_username=$user&j_password=$pwd";

      client.post("$_serverUrl/j_security_check", body: formData, headers: header).timeout(defaultTimeoutForAuth).then((http.Response responseLogin) async {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('JSESSIONID', cookie);

        if(responseLogin.statusCode == 403){
            var authError = AuthError();
           _completer.completeError(authError);
           return;
        }

        var headerUserRequest = builderHeader(toAdd: {'cookie': cookie});
        client.get("$_serverUrl/user.json", headers: headerUserRequest).then((http.Response responseUserLogged) {

          if(responseUserLogged.statusCode == 200){
            if(ProcessorClient.handleBodyObject(responseUserLogged.body, (String message){
               _completer.completeError(Exception(message));
               return;
            })){
                _completer.complete(responseUserLogged.body);
                return;
            }
          }
        }).catchError((dynamic error){
          _completer.completeError(error);
          return;
        });
      });
    }).catchError((dynamic onError){
      _completer.completeError(onError);
    });
    return _completer.future;
  }

  @override
  Future<http.Response> disconnect() async {
    Completer<http.Response> _completer = Completer<http.Response>();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('JSESSIONID');

    http.get("$_serverUrl/logout").timeout(defaultTimeoutForAuth).then((http.Response response){
      _completer.complete(response);
    }).catchError((dynamic onError){

      if(onError.runtimeType == TimeoutException){
        var excp = VizTimeoutException(defaultTimeoutForAuth.inSeconds);
        _completer.completeError(excp);
        return;
      }
      _completer.completeError(onError);

    });
    return _completer.future;
  }

  @override
  Future<String> get(String endPoint) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cookie = await prefs.get('JSESSIONID');
    Completer<String> _completer = Completer<String>();
    var header = builderHeader(toAdd: {'cookie': cookie});

    print('Request URL: ${"$_serverUrl/$endPoint"}');

    http.get("$_serverUrl/$endPoint", headers: header).timeout(defaultTimeoutForPulling).then((http.Response response) {
      print('Response Code: ${response.statusCode} Content-Type: ${response.headers['content-type']} Content-Length: ${response.contentLength}');
      print('\n');

      if (response.statusCode != 200) {
         _completer.completeError({'error': 'not an 200'});
      }

      if (!response.headers['content-type'].contains('application/json')) {
         _completer.completeError(NonJsonError());
      }

      if (ProcessorClient.handleBodyObject(response.body, (String msg) {
         _completer.completeError(msg);
      })) {
         _completer.complete(response.body);
      }
    }).catchError((dynamic onError){
      if(onError.runtimeType == TimeoutException){
        _completer.completeError(VizTimeoutException(defaultTimeoutForPulling.inSeconds));
        return;
      }
      _completer.completeError(onError);
    });
    return _completer.future;
  }

  @override
  Future<String> post(String endPoint, String body, {headers}) async {
    Completer<String> _completer = Completer<String>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cookie = await prefs.get('JSESSIONID');
    var header = {'cookie': cookie, 'Content-Type': 'application/xml' };
    String urlx = "$_serverUrl/$endPoint";
    print('url post $urlx' );
    print('body $body');

    http.post("$_serverUrl/$endPoint", headers: header, body: body).then((http.Response response)
    {
      if (response.statusCode != 200) {
        _completer.completeError('not an 200');
      }

      if (!response.headers['content-type'].contains('application/json')) {
        _completer.completeError(NonJsonError());
      }

       _completer.complete(response.body);
    });

    return _completer.future;
  }


  static bool handleBodyObject(String body, Function(String) errorReason) {
    if(body == null || body.isEmpty){
      errorReason('Empty body response');
      return false;
    }

    Map<String, dynamic> obj = json.decode(body);
    if (obj.containsKey('errorObject')) {
      Map<String, dynamic> errorObj = obj['errorObject'];
      String details = errorObj['details'];
      errorReason(details);
      return false;
    }
    return true;
  }



}
