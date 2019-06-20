import 'package:rxdart/rxdart.dart';
import 'package:techviz/model/task.dart';
import 'package:rxdart/subjects.dart';


class TaskViewBloc{
  static final TaskViewBloc _instance = TaskViewBloc._();
  factory TaskViewBloc() => _instance;

  final ReplaySubject<List<Task>> _taskController = ReplaySubject<List<Task>>();
  Stream<List<Task>> get stream => _taskController.stream;
  List<Task> get openTasks {
    print(_taskController.values.length);
    return _taskController.values.take(4).toList();
  }

  void update (Task task){
    _taskController.sink.add(task);
  }

  void dispose(){
    _taskController?.close();
  }
}