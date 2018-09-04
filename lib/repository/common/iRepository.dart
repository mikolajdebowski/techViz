
import 'dart:async';

abstract class IRepository<T> {
  Future fetch();
  Future listen();
  Future submit(T object);
}