class UserGeneralInfo{
  String Name;
  String UserName;
  int StaffID;
  int UserRoleID;

  UserGeneralInfo({this.Name, this.StaffID, this.UserRoleID});

  UserGeneralInfo.fromMap(Map map){
    Name = map['Name'] as String;
    UserName = map['UserName'] as String;
    StaffID = int.parse(map['StaffID'].toString());
    UserRoleID = int.parse(map['UserRoleID'].toString());
  }
}