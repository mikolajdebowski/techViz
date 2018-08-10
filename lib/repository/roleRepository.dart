import 'dart:async';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';

abstract class IRoleRepository implements IRepository<dynamic>{
  Future<List<Role>> getAll();
}

class RoleRepository implements IRoleRepository{

  /**
   * fetch local
   */
  @override
  Future<List<Role>> getAll() async {
    LocalRepository localRepo = LocalRepository();

    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery("SELECT 1 as ID, 'Role 1' as Description");

    List<Role> toReturn = List<Role>();
    queryResult.forEach((Map<String, dynamic> role) {
      var t = Role(
        id: role['ID'] as int,
        description: role['Description'] as String,
      );
      toReturn.add(t);
    });

    return toReturn;
  }

  /**
   * fetch remote
   */
  @override
  Future<List<dynamic>> fetch() {
    throw new UnimplementedError('Needs to be overwritten');
  }
}