import 'package:techviz/repository/local/localTable.dart';

class RoleTable extends LocalTable {
  RoleTable() {
    tableName = 'Role';
    createSQL = '''
              CREATE TABLE $tableName ( 
                  UserRoleID INT NOT NULL,
                  UserRoleName TEXT NOT NULL,
                  IsAttendant INT NOT NULL,
                  IsManager INT NOT NULL,
                  IsSupervisor INT NOT NULL,
                  IsTechManager INT NOT NULL,
                  IsTechnician INT NOT NULL,
                  IsTechSupervisor INT NOT NULL
                  )
              ''';
  }
}