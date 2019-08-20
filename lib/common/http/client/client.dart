import 'dart:async';
import 'package:http/http.dart' as http;

abstract class IHttpClient {
  Future<String> auth(String user, String pwd);
  Future<http.Response> disconnect();
  Future<String> get(String url);
  Future<String> post(String url, String body, {Map<String,String> headers});
}


abstract class VizHttpClient {
  Future<dynamic> get(String url);
}

enum ClientType{
  PROCESSOR,
  IHUB,
}

class AuthError extends Error{
  @override
  String toString() {
    return 'Invalid username or password.';
  }
}

class ServerUnreachableError extends Error{
  @override
  String toString() {
    return 'Server unreachable';
  }
}

class NonJsonError extends Error{
  @override
  String toString() {
    return 'not an application/json return';
  }
}
