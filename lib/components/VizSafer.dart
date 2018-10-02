import 'package:flutter/material.dart';

class VizSafeArea extends SafeArea{
  final Widget child;
  VizSafeArea(this.child);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}