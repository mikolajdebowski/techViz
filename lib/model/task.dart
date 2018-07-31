class Task {
  final String id;
  final String location;
  final String machineId;
  final int taskTypeID;
  final int taskStatusID;
  final DateTime taskCreated;
  final DateTime taskAssigned;
  final double amount;
  final String eventDesc;
  final String playerID;

  final String playerFirstName;
  final String playerLastName;
  final String playerTier;

  const Task({this.id, this.location, this.taskTypeID, this.taskStatusID, this.machineId, this.taskCreated, this.taskAssigned, this.amount, this.eventDesc, this.playerID,
  this.playerFirstName, this.playerLastName, this.playerTier});

}


/*
{
	"_ID": "123",
	"Location": "12-34-56",
	"TaskStatusID": 1,
	"TaskTypeID": 1,
	"TaskCreated": "2018-07-27 09:26:48.043"
}
*/