class ReassignUser{
  String userID;
  String userName;
  int sectionsCount;
  int taskCount;

  ReassignUser(this.userID, this.userName, this.sectionsCount, this.taskCount);

  ReassignUser.fromMap(Map map){
    userID =  map['UserID'].toString();
    userName =  map['UserName'].toString();
    sectionsCount =  map['TaskCount'] == ''? 0: int.parse(map['TaskCount'].toString());
    taskCount = map['SectionCount'] == ''? 0: int.parse(map['SectionCount'].toString());
  }
}