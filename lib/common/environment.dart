
class Environment {
  String _baseEndPoint;
  RabbitMQConfig _rabbitMQConfig;
  RestConfig _restConfig;

  String get baseEndPoint {
    return _baseEndPoint;
  }

  RabbitMQConfig get rabbitMQConfig {
    return _rabbitMQConfig;
  }

  RestConfig get restConfig {
    return _restConfig;
  }

  static final Environment _singleton = Environment._internal();
  factory Environment() {
    return _singleton;
  }
  Environment._internal();

  void init(String endPoint, {String rabbitMQExchangeName, String rabbitMQUser, String rabbitMQPassword, int rabbitMQPort, int restPort}) {
      assert(endPoint!=null);

      _baseEndPoint = endPoint;

      _rabbitMQConfig = RabbitMQConfig();
      _rabbitMQConfig.exchangeName = rabbitMQExchangeName;
      _rabbitMQConfig.user = rabbitMQUser;
      _rabbitMQConfig.password = rabbitMQPassword;
      _rabbitMQConfig.port = rabbitMQPort;


      _restConfig = RestConfig();
      _restConfig.port = restPort;
  }

  void save(){

  }

}

class RabbitMQConfig{
  int port;
  String user;
  String password;
  String exchangeName;
}

class RestConfig {
  int port;
}