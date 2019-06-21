import 'dart:async';
import 'dart:math';

import 'package:techviz/bloc/taskViewBloc.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';

class TaskService{
	static final TaskService _instance = TaskService._();
	factory TaskService() => _instance;
	TaskService._();

	void listen(){
		Timer.periodic(Duration(milliseconds: 500), (Timer timer) {
			int randon = 111111 + Random().nextInt(999999 - 111111);
			String randonHEX = randon.toString().padLeft(6);
			int randonTaskID = 1 + Random().nextInt(5 - 1);
			Task task = Task(
					id: '${randonTaskID.toString()}' ,
					location: randonTaskID.toString(),
					urgencyHEXColor: randonHEX,
					eventDesc: 'desc',
					taskType: TaskType(description: 'type$randonTaskID', taskTypeId: 1),
					taskStatus: TaskStatus(description: 'status$randonTaskID', id: 1),
					amount: 0,
					dirty: false
			);

			TaskViewBloc().update(task);
		});
	}
}