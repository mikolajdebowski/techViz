class TaskStatus{
  final int id;
  final String description;

  const TaskStatus({this.id, this.description});

  @override
  String toString(){
    return description;
  }
}