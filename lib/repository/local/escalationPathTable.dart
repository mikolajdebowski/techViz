import 'package:techviz/repository/local/localTable.dart';

class EscalationPathTable extends LocalTable{

  EscalationPathTable(){
    this.tableName = 'EscalationPath';
    this.createSQL = '''
              CREATE TABLE $tableName ( 
                  EscalationPathId INT PRIMARY KEY NOT NULL, 
                  Description TEXT NOT NULL,
                  LookupName TEXT NOT NULL)
              ''';
  }
}
