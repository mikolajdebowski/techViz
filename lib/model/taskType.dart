class TaskType{
  final int taskTypeId;
  final String description;
  final String lookupName;

  const TaskType(this.taskTypeId, this.description, this.lookupName);

  @override
  String toString(){
    return description;
  }
}