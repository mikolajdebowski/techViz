import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:techviz/adapters/searchAdapter.dart';
import 'dart:convert';

class SlotAdapter implements SearchAdapter<MachineModel>{

  @override
  Future<List<MachineModel>> find() async {
    var response = await http.get('https://jsonplaceholder.typicode.com/posts');

    List mapList = json.decode(response.body) as List;

    var toReturn = new List<MachineModel>();
    mapList.forEach((dynamic element) {
      Map map = element as Map;
      toReturn.add(MachineModel.fromJson(map));
    });
    return toReturn;
  }

  @override
  List<Widget> render(List<MachineModel> list) {
    var listMapped = list.map((MachineModel t) => Padding(padding: const EdgeInsets.all(5.0), child: Text(t.location, style: TextStyle(color: Colors.white))));
    return listMapped.toList();
  }
}

class MachineModel {
  final String location;
  MachineModel({this.location});
  factory MachineModel.fromJson(Map json) {
    return MachineModel(
      location: json['title'] as String
    );
  }
}