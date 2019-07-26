import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/repository/local/localTable.dart';

import 'localRepository.dart';

class EscalationPathTable extends LocalTable {
  EscalationPathTable(ILocalRepository localRepo): super(localRepo: localRepo){
    tableName = 'EscalationPath';
    createSQL = '''
              CREATE TABLE $tableName ( 
                  EscalationPathId INT PRIMARY KEY NOT NULL, 
                  Description TEXT NOT NULL,
                  LookupName TEXT NOT NULL,
                  IsTechPath INT NOT NULL)
              ''';
  }

  Future<List<EscalationPath>> getAll(bool techPaths) async {

    List<Map<String, dynamic>> queryResult = await localRepo.db.query(
        tableName,
        where: 'IsTechPath = ?',
        whereArgs: [techPaths? 1 : 0].toList());

    List<EscalationPath> output = queryResult.map((Map<String, dynamic> entry) => parser(entry)).toList();
    return output;
  }

  EscalationPath parser(Map<String, dynamic> entry){
    return EscalationPath(
        entry['EscalationPathId'] as int,
        entry['Description'] as String,
        entry['LookupName'] as String,
        false,
    );
  }
}
