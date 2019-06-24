 import 'dart:async';
import 'package:techviz/bloc/taskViewBloc.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/async/TaskRouting.dart';

import '../repository.dart';
import '../taskRepository.dart';

class TaskService{
	static final TaskService _instance = TaskService._();
	factory TaskService() => _instance;
	TaskService._();

	StreamSubscription<List<Task>> _streamSubscriptionLocal;
	TaskRouting taskRouting = TaskRouting();

	void listenRemote(){
		taskRouting.ListenQueue((dynamic receivedTask) async {
			TaskRepository repo = Repository().taskRepository;

			dynamic mapped = {
				'_ID': receivedTask['_ID'].toString(),
				'_VERSION': receivedTask['_version'].toString(),
				'_DIRTY': false,
				'USERID': receivedTask['userID'].toString(),
				'MACHINEID': receivedTask['userID'].toString(),
				'TASKSTATUSID': int.parse(receivedTask['taskStatusID'].toString()),
				'TASKTYPEID': int.parse(receivedTask['taskTypeID'].toString()),
				'TASKURGENCYID': int.parse(receivedTask['taskUrgencyID'].toString()),
				'LOCATION': receivedTask['location'].toString(),
				'TASKCREATED': receivedTask['taskCreated'].toString(),
				'TASKASSIGNED': receivedTask['taskAssigned'].toString(),
				'LOCATION': receivedTask['location'].toString(),
				'AMOUNT': receivedTask['AMOUNT']==null? 0.0: double.parse(receivedTask['AMOUNT'].toString()),
				'EVENTDESC': receivedTask['eventDesc'].toString(),
				'PLAYERID': receivedTask['playerID'].toString(),
				'PLAYERFIRSTNAME': receivedTask['firstname'].toString(),
				'PLAYERLASTNAME': receivedTask['lastName'].toString(),
				'PLAYERTIER': receivedTask['tier'].toString(),
				'PLAYERTIERCOLORHEX': receivedTask['tierColorHex'].toString(),
			};

			await repo.insertOrUpdate(mapped);
			Task taskOutput = await repo.getTask(receivedTask['_ID'].toString());

			//only tasks with status 1,2,3 should be considered opentasks
			if([1,2,3].contains(taskOutput.taskStatus.id)){
				TaskViewBloc().update(taskOutput);
			}

		});

//		Timer.periodic(Duration(milliseconds: 500), (Timer timer) {
//			int randon = 111111 + Random().nextInt(999999 - 111111);
//			String randonHEX = randon.toString().padLeft(6);
//			int randonTaskID = 1 + Random().nextInt(5 - 1);
//			Task task = Task(
//					id: '${randonTaskID.toString()}' ,
//					location: randonTaskID.toString(),
//					urgencyHEXColor: randonHEX,
//					eventDesc: 'desc',
//					taskType: TaskType(description: 'type$randonTaskID', taskTypeId: 1),
//					taskStatus: TaskStatus(description: 'status$randonTaskID', id: 1),
//					amount: 0,
//					dirty: false
//			);
//
//			TaskViewBloc().update(task);
//		});
	}

	void listenLocal(){
		void onTaskListReceived(List<Task> event) {
			event.forEach((Task task) {
				if(task.dirty){

				}
			});
		}

		void onTaskListenError(dynamic error) {
			print(error);
		}

		_streamSubscriptionLocal = TaskViewBloc().openTasks.listen(onTaskListReceived, onError: onTaskListenError);
	}

  void shutdown(){
		_streamSubscriptionLocal?.cancel();
	}
}