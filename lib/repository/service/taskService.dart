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
	StreamController<dynamic> _streamControllerRemote;
	TaskRouting taskRouting = TaskRouting();


	/*
	* this method listens to the rabbitmq service for tasks and push them into the stream
	* */
	void listenRemote(){
		_streamControllerRemote = taskRouting.ListenQueue((dynamic receivedTask) async {
			TaskRepository repo = Repository().taskRepository;

			print(receivedTask);

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
				'ISTECHTASK': int.parse(receivedTask['IsTechTask'].toString()),
			};

			await repo.insertOrUpdate(mapped);
			Task taskOutput = await repo.getTask(receivedTask['_ID'].toString());

			TaskViewBloc().update(taskOutput);
		});
	}


	/*
	* this method listens to the local stream for tasks modified by the user and send these tasks to the rabbitmq service
	* */
	void listenLocal(){

		Future updateStatus(Task task){
			return Repository().taskRepository.update(
					task.id,
					taskStatusID: task.taskStatusID.toString(),
					cancellationReason: task.cancellationReason
			);
		}

		Future escalate(Task task){
			return Repository().taskRepository.escalateTask(
					task.id, task.escalationPath, escalationTaskType: task.escalationTaskType, notes: task.notes
			);
		}

		void onTaskListReceived(List<Task> event) {
			Future.forEach(event, (Task task){
				if(task.dirty == 1){
					print('Sending ${task.location} status ${task.taskStatusID} due dirty == 1\n');

					Future futureAction;
					switch(task.taskStatusID){
						case 2:
						case 3:
						case 12:
						case 13:
						case 31:
						case 32:
						case 33:
							futureAction = updateStatus(task);
							break;
						case 5:
							futureAction = escalate(task);
					}

					futureAction.then((dynamic result){
						print('Sent! output: $result');
						task.dirty = 2;
						TaskViewBloc().update(task);
					}).catchError((dynamic error){
						throw error;
					});
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
		_streamControllerRemote.onCancel = (){
			print('_streamControllerRemote cancelled');
		};
		_streamControllerRemote.close();
	}
}