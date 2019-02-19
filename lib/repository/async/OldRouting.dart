import 'dart:async';

abstract class OldRouting{
  Future PublishMessage(dynamic object);
  void ListenQueue(Function callback, {Function callbackError});
}