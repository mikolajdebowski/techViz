class TaskStatus{
  final int id;
  final String description;

  const TaskStatus({this.id, this.description});

  @override
  toString(){
    return description;
  }
}