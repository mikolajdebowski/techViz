import 'dart:async';

abstract class IRemoteChannel<T>{
  Future submit(T object);
}