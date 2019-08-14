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

			Map<String,dynamic> mapped = <String,dynamic>{};
			mapped['_ID'] = receivedTask['_ID'];
			mapped['_VERSION'] = receivedTask['_version'];
			mapped['_DIRTY'] = false;
			mapped['USERID'] = receivedTask['userID'];
			mapped['MACHINEID'] = receivedTask['machineID'];
			mapped['LOCATION'] = receivedTask['location'];
			mapped['ISTECHTASK'] = int.parse(receivedTask['IsTechTask'].toString());
			mapped['TASKSTATUSID'] = int.parse(receivedTask['taskStatusID'].toString());
			mapped['TASKTYPEID'] = int.parse(receivedTask['taskTypeID'].toString());
			mapped['TASKURGENCYID'] = int.parse(receivedTask['taskUrgencyID'].toString());
			mapped['TASKCREATED'] = receivedTask['taskCreated'];
			mapped['TASKASSIGNED'] = receivedTask['taskAssigned'];

			mapped['EVENTDESC'] = receivedTask['eventDesc'];
			mapped['AMOUNT'] = receivedTask['amount']==null? 0.0: double.parse(receivedTask['amount'].toString());

			mapped['PLAYERID'] = receivedTask['playerID'];
			mapped['PLAYERFIRSTNAME'] = receivedTask['firstName'];
			mapped['PLAYERLASTNAME'] = receivedTask['lastName'];
			mapped['PLAYERTIER'] = receivedTask['tier'];
			mapped['PLAYERTIERCOLORHEX'] = receivedTask['tierColorHex'];



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
					}

					if(futureAction!=null){
						futureAction.then((dynamic result){
							print('Sent! output: $result');
							task.dirty = 2;
							TaskViewBloc().update(task);
						}).catchError((dynamic error){
							throw error;
						});
					}
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