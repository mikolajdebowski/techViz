import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:techviz/adapters/searchAdapter.dart';
import 'dart:convert';

class MachineAdapter implements SearchAdapter<MachineModel>{
  @override
  Future<List<MachineModel>> find() async {
    //await Future.delayed(const Duration(seconds: 5), () => "1");

    final response = await http.get('https://jsonplaceholder.typicode.com/posts');
    final responseJson = json.decode(response.body).cast<Map<String, dynamic>>();
    return responseJson.map<MachineModel>((json) => new MachineModel.fromJson(json)).toList();
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
      location: json['title']
    );
  }

}