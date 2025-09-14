
class BuildEnv {
  static const apiBaseUrl =
  String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.1.102:3000');

  static const brokerHost =
  String.fromEnvironment('BROKER_HOST', defaultValue: '192.168.1.102');

  static const brokerPort =
  int.fromEnvironment('BROKER_PORT', defaultValue: 1883);

  static const brokerUser =
  String.fromEnvironment('BROKER_APP_USER', defaultValue: 'app-user');

  static const brokerTls =
  bool.fromEnvironment('BROKER_TLS', defaultValue: false);

  static const brokerWs =
  bool.fromEnvironment('BROKER_WS', defaultValue: false);
}
