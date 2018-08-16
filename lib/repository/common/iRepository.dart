
import 'dart:async';

abstract class IRepository<T> {
  Future fetch();
}