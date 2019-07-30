import 'dart:convert';

import 'package:http/http.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorClientMock implements IHttpClient{
  dynamic processorResponse;
  ProcessorClientMock(this.processorResponse);

  @override
  Future<String> auth(String user, String pwd) {
    throw UnimplementedError();
  }

  @override
  Future<Response> disconnect() {
    throw UnimplementedError();
  }

  @override
  Future<String> get(String url) {
    return Future<String>.value(jsonEncode(processorResponse));
  }

  @override
  Future<String> post(String url, String body, {Map<String, String> headers}) {
    throw UnimplementedError();
  }
}