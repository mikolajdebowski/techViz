import 'package:sqflite/sqlite_api.dart';
import 'package:techviz/repository/local/localRepository.dart';

import 'databaseMock.dart';

class LocalRepositoryMock implements ILocalRepository{
  @override
  Database get db => DatabaseMock();
}
