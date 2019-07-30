import 'package:sqflite/sqlite_api.dart';
import 'package:techviz/repository/local/localRepository.dart';

import 'databaseMock.dart';

class LocalRepositoryMock implements ILocalRepository{
  List<Map<String,dynamic>> values;
  LocalRepositoryMock({this.values});

  @override
  Database get db => DatabaseMock(values);
}
