import 'dart:async';

import 'package:techviz/repository/async/MessageClient.dart';

class MessageClientMock implements IMessageClient{
	@override
	Future Close() {
		throw UnimplementedError();
	}

	@override
	Future Init() {
		throw UnimplementedError();
	}

	@override
	StreamController ListenQueue(String routingKeyPattern, Function onData, {Function onError, bool timeOutEnabled = true, Function parser, bool appendDeviceID = true}) {
		throw UnimplementedError();
	}

	@override
	Future PublishMessage(dynamic object, String routingKeyPattern, {bool wait = false, Function parser}) {
		return Future<bool>.value(true);
	}

	@override
	void ResetChannel() {
		throw UnimplementedError();
	}

}
