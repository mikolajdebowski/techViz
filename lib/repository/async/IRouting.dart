import 'dart:async';

abstract class IRouting<T>{
  StreamController<T> Listen();
  Future PublishMessage(dynamic message);
}