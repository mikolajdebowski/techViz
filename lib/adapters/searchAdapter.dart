import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract class SearchAdapter<T>{
  Future<List<T>> find();
  List<Widget> render(List<T> t);
}