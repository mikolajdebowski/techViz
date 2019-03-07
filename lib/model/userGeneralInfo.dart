class UserGeneralInfo{
  String name;
  String userName;
  int staffID;
  int userRoleID;

  UserGeneralInfo({this.name, this.staffID, this.userRoleID});

  UserGeneralInfo.fromMap(Map map){
    name = map['Name'] as String;
    userName = map['UserName'] as String;
    staffID = int.parse(map['StaffID'].toString());
    userRoleID = int.parse(map['UserRoleID'].toString());
  }
}