import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract class SearchAdapter<T>{
  Future find(String query);
  List<Widget> render(List<T> t);
}