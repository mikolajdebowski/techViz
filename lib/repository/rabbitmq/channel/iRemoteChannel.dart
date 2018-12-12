import 'dart:async';
abstract class IRemoteChannel<T,X>{
  Future<X> publishMessage(T object, {String deviceID});
}