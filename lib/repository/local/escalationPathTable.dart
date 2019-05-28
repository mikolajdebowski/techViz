import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/repository/local/localTable.dart';

class EscalationPathTable extends LocalTable {
  EscalationPathTable() {
    tableName = 'EscalationPath';
    createSQL = '''
              CREATE TABLE $tableName ( 
                  EscalationPathId INT PRIMARY KEY NOT NULL, 
                  Description TEXT NOT NULL,
                  LookupName TEXT NOT NULL)
              ''';
  }

  Future<List<EscalationPath>> getAll() async {
    return super.defaultGetAll<EscalationPath>(parserFnc);
  }

  EscalationPath parserFnc(Map<String, dynamic> entry){
    return EscalationPath(entry['EscalationPathId'] as int, entry['Description'] as String, entry['LookupName'] as String);
  }
}
