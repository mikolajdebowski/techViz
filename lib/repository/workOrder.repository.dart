import 'package:intl/intl.dart';

import 'async/MessageClient.dart';

abstract class IWorkOrderRepository{
	Future create(String userID, int taskTypeID, {String location, String mNumber, String notes, DateTime dueDate});
}

class WorkOrderRepository implements IWorkOrderRepository{
	IMessageClient iMessageClient;
	WorkOrderRepository(this.iMessageClient){
		assert(iMessageClient!=null);
	}

	@override
  Future create(String userID, int taskTypeID, {String location, String mNumber, String notes, DateTime dueDate}) {
		Map<String, dynamic> payload = <String, dynamic>{};
		payload['userID'] = userID;
		payload['workOrderStatusID'] = 0; //CREATING
		payload['location'] = location;
		payload['taskTypeID'] = taskTypeID;
		payload['mNum'] = mNumber;

		payload['notes'] = notes;
		payload['dueDate'] = dueDate!=null? DateFormat("yyyy-MM-dd").format(dueDate) : null;

		return iMessageClient.PublishMessage(payload, "mobile.workorder", wait: true);
  }
}

/*
	{
		"userID": "dev1",
		"workOrderStatusID": 0,
		"location": "12-12-12",
		"taskTypeID": 1,
		"mNum": 123,
		"notes": "etc etc etc",
		"dueDate": "2019-08-06"  //YYYY-MM-DD,
		"deviceID": "123456789"
	}
*/