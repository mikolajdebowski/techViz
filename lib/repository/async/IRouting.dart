
abstract class IRouting{
  Future PublishMessage(dynamic object);
  void ListenQueue(Function callback, {Function callbackError});
}