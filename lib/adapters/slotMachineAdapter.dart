//import 'dart:async';
//import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'package:techviz/adapters/searchAdapter.dart';
//import 'dart:convert';
//
//import 'package:techviz/model/slotMachine.dart';
//import 'package:techviz/repository/processor/processorSlotLookupRepository.dart';
//
//class SlotMachineAdapter implements SearchAdapter<SlotMachine>{
//
//  @override
//  Future<List<SlotMachine>> find(String query) async {
//    var repo = ();
//    return repo.search(query);
//  }
//
//  @override
//  List<Widget> render(List<SlotMachine> list) {
//    var borderColor = Border.all(color: Colors.grey, width: 0.5);
//
//    var txtStyle = TextStyle(color: Colors.black54);
//    var txtStyleOdd = TextStyle(color: Colors.white);
//    var backgroundEven = Color(0xFFfafafa);
//    var backgroundOdd = Color(0xFFeef5f5);
//
//    var decorationEven = BoxDecoration(border: borderColor, color: backgroundEven);
//
//    int idx = -1;
//
//    var listMapped = list.map((SlotMachine t) {
//      idx++;
//
//
//      );
//    });
//    return listMapped.toList();
//  }
//}
