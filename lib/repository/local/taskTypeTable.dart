import 'package:techviz/repository/local/localTable.dart';

class TaskTypeTable extends LocalTable{
  TaskTypeTable(){
    tableName = 'TaskType';
    createSQL = '''
              CREATE TABLE $tableName ( 
                  TaskTypeID INT PRIMARY KEY NOT NULL, 
                  TaskTypeDescription TEXT NOT NULL,
                  LookupName TEXT NOT NULL)
              ''';
  }
}