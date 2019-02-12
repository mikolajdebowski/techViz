
import 'dart:async';

abstract class IRepository<T> {
  Future fetch();
  Future listen(Function callback, Function callbackError);
}