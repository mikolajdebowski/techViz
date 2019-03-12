import 'package:techviz/repository/local/localTable.dart';

class TaskTypeTable extends LocalTable{
  TaskTypeTable(){
    this.tableName = 'TaskType';
    this.createSQL = '''
              CREATE TABLE $tableName ( 
                  TaskTypeID INT PRIMARY KEY NOT NULL, 
                  TaskTypeDescription TEXT NOT NULL,
                  LookupName TEXT NOT NULL)
              ''';
  }
}