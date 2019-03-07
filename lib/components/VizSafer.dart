import 'package:flutter/material.dart';

class VizSafeArea extends SafeArea{
  @override
  final Widget child;
  VizSafeArea(this.child);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}