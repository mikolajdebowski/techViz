import 'package:techviz/service/client/MQTTClientService.dart';

class RabbitMQConfigMock extends RabbitmqConfig{
  RabbitMQConfigMock(){
    port = 80;
    broker = 'irrelevantBroker';
    exchangeName = 'irrelevantExchangeName';
    secure = false;
  }
}