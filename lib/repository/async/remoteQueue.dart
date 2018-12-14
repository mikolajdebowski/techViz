typedef RemoteQueueCallback<T> = void Function(T json);

abstract class IRemoteQueue<T>{
  void listen(RemoteQueueCallback callback);
}