
import 'dart:async';

abstract class IRepository<T> {
  Future<List<T>> fetch();
}