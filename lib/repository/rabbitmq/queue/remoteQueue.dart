import 'dart:async';

abstract class IRemoteQueue<T>{
  Future listen();
}