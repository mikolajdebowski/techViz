
abstract class IRouting{
  Future PublishMessage(dynamic object, {Function callback, Function callbackError});
  void ListenQueue(Function callback, {Function callbackError});
}