import 'dart:async';

import 'package:techviz/repository/local/localRepository.dart';

class LocalTable{
  String tableName;
  String createSQL;

  Future<void> create() async {
    LocalRepository localRepo = LocalRepository();
      await localRepo.open();
    return localRepo.db.execute(createSQL);
  }

  Future<int> cleanUp() async {
    LocalRepository localRepo = LocalRepository();
      await localRepo.open();
    return await localRepo.db.delete(tableName);
  }

  Future<int> insert(dynamic toInsert) async {
    Completer<int> _completer = Completer<int>();

    int insertedRows = 0;
    LocalRepository localRepo = LocalRepository();
    await localRepo.open();

    Future.forEach<Map<String, dynamic>>(toInsert, (Map<String, dynamic> entry) async{
      insertedRows += await localRepo.db.insert(tableName, entry);
    }).then((dynamic d){
      _completer.complete(insertedRows);
    });

    return _completer.future;
  }

  Future<List<T>> defaultGetAll<T>(Function parser) async {
    LocalRepository localRepo = LocalRepository();
    if (localRepo.db.isOpen == false)
      await localRepo.open();

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery('SELECT * FROM $tableName');

    List<T> toReturn = List<T>();

    queryResult.forEach((Map<String, dynamic> ep) {
      toReturn.add(parser(ep));
    });

    return Future.value(toReturn);
  }
}