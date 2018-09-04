import 'dart:async';

abstract class IRemoteRepository<T>{
  Future fetch();
}