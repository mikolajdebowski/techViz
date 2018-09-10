import 'dart:async';

typedef RemoteQueueCallback<T> = void Function(T json);

abstract class IRemoteQueue<T>{
  Future listen(RemoteQueueCallback callback);
}