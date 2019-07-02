import 'package:sqflite/sqlite_api.dart';

class DatabaseMock implements Database{
  List<Map<String,dynamic>> values;
  DatabaseMock(this.values);

  @override
  Batch batch() {
    throw UnimplementedError();
  }

  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  Future<int> delete(String table, {String where, List whereArgs}) {
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeMethod<T>(String method, [dynamic arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql, [List arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<void> execute(String sql, [List arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<int> getVersion() {
    throw UnimplementedError();
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values, {String nullColumnHack, ConflictAlgorithm conflictAlgorithm}) {
    return Future<int>.value(1);
  }

  @override
  bool get isOpen => null;

  @override
  String get path => null;

  @override
  Future<List<Map<String, dynamic>>> query(String table, {bool distinct, List<String> columns, String where, List whereArgs, String groupBy, String having, String orderBy, int limit, int offset}) {
    return Future<List<Map<String,dynamic>>>.value([]);
  }

  @override
  Future<int> rawDelete(String sql, [List arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<int> rawInsert(String sql, [List arguments]) {
    return Future<int>.value(1);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List arguments]) {
    if(values==null){
      return Future<List<Map<String,dynamic>>>.value([]);
    }

    List<Map<String,dynamic>> output = values.toList();
    return Future<List<Map<String,dynamic>>>.value(output);
  }

  @override
  Future<int> rawUpdate(String sql, [List arguments]) {
    return Future<int>.value(1);
  }

  @override
  Future<void> setVersion(int version) {
    throw UnimplementedError();
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action, {bool exclusive}) {
    throw UnimplementedError();
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String where, List whereArgs, ConflictAlgorithm conflictAlgorithm}) {
    return Future<int>.value(1);
  }
}