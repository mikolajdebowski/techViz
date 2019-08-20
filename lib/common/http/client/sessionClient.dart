import 'dart:async';
import 'client.dart';

class SessionClient {
  IHttpClient _client;
  static final SessionClient _instance = SessionClient._internal();

  factory SessionClient() {
    return _instance;
  }
  SessionClient._internal();

  void init(IHttpClient client) {
    _client = client;
  }

  Future<String> auth(String user, String pwd)  {
    return _client.auth(user, pwd);
  }

  Future<String> get(String url)  {
    return _client.get(url);
  }

  Future<String> post(String url, String body, {dynamic headers}) {
    return _client.post(url, body, headers: headers);
  }

  bool abandon() {
    return _client.disconnect != null;
  }
}
