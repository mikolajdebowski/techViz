import 'dart:async';

import 'package:techviz/repository/async/MessageClient.dart';

class MessageClientMock<T> implements IMessageClient{
	StreamController<T> fakeStreamController;
	MessageClientMock(this.fakeStreamController);

	@override
	Future Close() {
		throw UnimplementedError();
	}

	@override
	Future Connect() {
		throw UnimplementedError();
	}

	@override
	StreamController ListenQueue(String routingKeyPattern, Function onData, {Function onError, bool timeOutEnabled = true, Function parser, bool appendDeviceID = true}) {
		return fakeStreamController;
	}

	@override
	Future PublishMessage(dynamic object, String routingKeyPattern, {bool wait = false, Function parser}) {
		Completer _completer = Completer<dynamic>();

		fakeStreamController.stream.listen((dynamic data){
			_completer.complete(data);
		});

		return _completer.future;
	}

	@override
	void ResetChannel() {
		throw UnimplementedError();
	}

}
